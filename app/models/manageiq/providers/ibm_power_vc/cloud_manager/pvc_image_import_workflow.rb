class ManageIQ::Providers::IbmPowerVc::CloudManager::PvcImageImportWorkflow < ManageIQ::Providers::AnsiblePlaybookWorkflow
  require_nested :PvcImportDispatcher

  def load_transitions
    super.merge(
      :pre_execute      => {'pre_execute' => 'pre_execute_poll'},
      :pre_execute_poll => {'pre_execute_poll' => '*'}
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

    pvs.with_provider_connection(:service => 'PCloudImagesApi') do |api|
      response = api.pcloud_cloudinstances_images_export_post(pvs.uid_ems, options[:miq_img][:uid_ems], options[:cos_pvs_creds], {})
      context[:task_id] = response[:taskID]
      update!(:context => context)

      message = 'initiated PVS image export to COS'
      signal = :pre_execute_poll
      status = 'ok'
    rescue => e
      _log.error("OVA image export failure: '#{e.message}'")

      message = trunc_err_msg(e.message)
      signal = nil
      status = 'error'
    end

    return message, status, signal
  end

  def pre_execute
    verify_options
    prepare_repository

    message, status, signal = export_image_to_cos(options)

    set_status(message, status)
    queue_signal(signal, message, status)
  end

  def pre_execute_poll(*args)
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
      when 'creating', 'compressing', 'uploading'
        context[:retry] = 0
        message = "importing image into PVS, current state is: '#{response.status}'"
        signal = :pre_execute_poll
        status = 'ok'
      when 'completed'
        message = 'importing image into image registry has completed'
        signal = :execute
        status = 'ok'
      when 'failed'
        raise "importing into image registry failed: '#{trunc_err_msg(response.status)}'"
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
      queue_signal(signal, message, status, :deliver_on => deliver)
    end
  end

  def post_execute(*args)
    # TODO: implement
    _log.info("cleanup procedure")
  end

  def finish(*args)
    super(*args)
    post_poll_cleanup(*args)
  end

  def abort(*args)
    super(*args)
    # TODO: how to handle fatal error (roll-back changes)?
    post_poll_cleanup(*args)
  end

  def cancel(*args)
    super(*args)
    # TODO: how to handle user cancellation (roll-back changes)?
    post_poll_cleanup(*args)
  end
end
