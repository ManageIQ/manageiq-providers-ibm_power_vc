class ManageIQ::Providers::IbmPowerVc::CloudManager::PvcImageImportWorkflow < ManageIQ::Providers::AnsiblePlaybookWorkflow
  require_nested :PvcImportDispatcher

  def load_transitions
    super.merge(
      :pre_execute      => {'pre_execute'      => 'pre_execute_poll'},
      :pre_execute_poll => {'pre_execute_poll' => 'pre_execute_poll'},
      :execute          => {'pre_execute_poll' => 'running'}
    )
  end

  def trunc_err_msg(error_msg)
    max_err_sz = 1024
    trunc_msg = '[TRUNCATED OUTPUT - see full description in the server logs];' if !error_msg.nil? && (error_msg.length > max_err_sz)
    "#{trunc_msg}#{error_msg&.truncate(max_err_sz)}"
  end

  def try_extract_api_error(api_e)
    JSON.parse(api_e.response_body)["description"] if api_e.response_body
  rescue JSON::ParserError => e
    _log.warn("unable to parse the error description as a JSON: '#{e.message}'")
  end

  def export_image_to_cos(options)
    pvs = ExtManagementSystem.find(options[:src_provider_id])

    message = nil
    signal = nil
    status = nil

    cos_data = options[:cos_data]
    region = cos_data[:region]
    bucket_name = cos_data[:bucketName]

    cos = ExtManagementSystem.find_by(:id => cos_data[:cos_id])
    raise MiqException::Error, _("unable to find cloud object storage by this id '#{options['obj_storage_id']}'") if cos.nil?

    _, _, _, _, access_key, secret_key = cos.cos_creds

    body = {
      :region     => region,
      :bucketName => bucket_name,
      :accessKey  => access_key,
      :secretKey  => secret_key,
    }

    pvs.with_provider_connection(:service => 'PCloudImagesApi') do |api|
      response = api.pcloud_cloudinstances_images_export_post(pvs.uid_ems, options[:img_id], body, {})
      context[:task_id] = response[:taskID]
      update!(:context => context)

      message = 'initiated PVS image export to COS'
      signal = :pre_execute_poll
      status = 'ok'
    rescue => e
      _log.error("OVA image export failure: '#{e.message}'")

      message = trunc_err_msg(e.message)
      signal = :abort
      status = 'error'
    end

    return message, status, signal
  end

  def start
    queue_signal(:pre_execute, :msg_timeout => options[:timeout])
  end

  def pre_execute
    verify_options
    prepare_repository

    message, status, signal = export_image_to_cos(options)

    if signal == :abort
      queue_signal(signal)
    else
      queue_signal(signal, message, status)
    end

    set_status(message, status)
  end

  def pre_execute_poll(*_args)
    ems = ExtManagementSystem.find(options[:src_provider_id])
    max_retries = 10

    message = nil
    signal  = nil
    status  = nil
    deliver = nil

    ems.with_provider_connection(:service => 'PCloudTasksApi') do |api|
      begin
        response = api.pcloud_tasks_get(context[:task_id])
      rescue IbmCloudPower::ApiError => e
        retr = context[:retry].to_i
        raise "unable to get task status after #{max_retries} tries, see server logs" if retr >= max_retries

        context[:retry] = retr + 1

        error_dsc = trunc_err_msg(try_extract_api_error(e))
        message = "failed to retrieve cloud-task: '#{error_dsc}'; try #{retr + 1}/#{max_retries}"
        deliver = Time.now.utc + 1.minute
        signal = :pre_execute_poll
        status = 'error'
        break
      end

      case response.status
      when 'capturing', 'downloading', 'creating', 'deleting', 'compressing', 'loading', 'started', 'uploading'
        context[:retry] = 0
        message = "exporting image onto COS, current state is: '#{response.status}'"
        signal = :pre_execute_poll
        status = 'ok'
      when 'completed'
        message = 'exporting image from PVS image registry has completed'
        signal = :execute
        status = 'ok'
      when 'failed'
        raise "exporting from PVS image registry failed: '#{trunc_err_msg(response.status)}'"
      else
        raise "incompatible API, unexpected status: '#{response.status}'"
      end
    rescue => e
      signal = :abort
      status = 'error'
      message = e.message
    ensure
      update!(:context => context)
      set_status(message, status)
      queue_signal(signal, :deliver_on => deliver)
    end
  end

  def post_poll_cleanup(*args)
    ems = ExtManagementSystem.find(options[:ems_id])
    ems.remove_import_auth(options[:import_creds_id])
    ems.remove_ssh_auth(options[:ssh_creds_id]) if options[:ssh_creds_id]
    return if options[:keep_ova] == true

    begin
      cos = ExtManagementSystem.find(options[:cos_id])
      cos.remove_object(options[:cos_data][:bucketName], "#{options[:miq_img]}.ova.gz")
    rescue => e
      result = args[0]
      set_status("#{result}; cleanup result: cannot remove transient OVA image: #{trunc_err_msg(e.message)}", 'error')
      _log.error("#{result}; cleanup result: cannot remove transient OVA image: #{e.message}")
    end

    _log.info("cleanup procedure")
  end

  def finish(*args)
    super(*args)
    post_poll_cleanup(*args)
  end

  def abort(*args)
    super(*args)
    post_poll_cleanup(*args)
  end

  def cancel(*args)
    super(*args)
    post_poll_cleanup(*args)
  end
end
