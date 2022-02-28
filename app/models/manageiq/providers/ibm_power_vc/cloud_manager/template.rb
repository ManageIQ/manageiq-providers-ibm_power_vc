ManageIQ::Providers::Openstack::CloudManager::Template.include(ActsAsStiLeafClass)

class ManageIQ::Providers::IbmPowerVc::CloudManager::Template < ManageIQ::Providers::Openstack::CloudManager::Template
  has_and_belongs_to_many :cloud_tenants,
                          :foreign_key             => "vm_id",
                          :join_table              => "cloud_tenants_vms",
                          :association_foreign_key => "cloud_tenant_id",
                          :class_name              => "ManageIQ::Providers::IbmPowerVc::CloudManager::CloudTenant"

  extend ActiveSupport::Concern

  supports :import_image

  def self.raw_import_image(ext_management_system, options = {})
    session_id = SecureRandom.uuid
    wrkfl_timeout = options['timeout'].to_i.hours

    cos = ExtManagementSystem.find(options['obj_storage_id'])
    raise MiqException::Error, _("unable to find cloud object storage by this id '#{options['obj_storage_id']}'") if cos.nil?

    location = ext_management_system.endpoint(:default).hostname
    node_auth = ext_management_system.node_auth
    guid, apikey, region, endp, _, _ = cos.cos_creds
    bucket = bucket_name(options['bucket_id'])
    diskType = CloudVolumeType.find(options['disk_type_id']).ems_ref

    cos_data = {:cos_id => cos.id, :region => region, :bucketName => bucket}
    cos_ans_creds = {:resource_instance_id => guid, :apikey => apikey, :bucket_name => bucket, :url_endpoint => endp}
    encr_cos_creds, encr_cos_key, encr_cos_iv = encrypt_with_aes(cos_ans_creds)

    # FIXME: fixing the value of the rcfile location until a secure way of
    # FIXME: env variable passing is implemented in the corresp. playbook
    rcfile = '/opt/ibm/powervc/powervcrc'

    extra_vars = {
      :session_id  => session_id,
      :provider_id => options['src_provider_id'],
      :image_name  => MiqTemplate.find(options['src_image_id']).name,
      :powervc_rc  => rcfile,
      :disk_type   => diskType,
    }

    ssh_creds = set_ssh_pkey_auth(options['dst_provider_id'], node_auth.auth_key, node_auth.auth_key_password)
    import_creds = set_import_auth(options['dst_provider_id'], encr_cos_key, encr_cos_iv, encr_cos_creds)
    credentials = [import_creds, ssh_creds]

    host = "[powervc]\n#{location}\n[powervc:vars]\nansible_connection=ssh\nansible_user=#{node_auth.userid}"

    workflow_opts = {
      :keep_ova        => options['keep_ova'],
      :session_id      => session_id,
      :ems_id          => ext_management_system.id,
      :src_provider_id => options['src_provider_id'].to_i,
      :cos_id          => options['obj_storage_id'],
      :miq_img         => get_image_info(options['src_image_id'])[:name],
      :img_id          => MiqTemplate.find(options['src_image_id']).ems_ref,
      :cos_data        => cos_data,
      :import_creds_id => import_creds,
      :ssh_creds_id    => ssh_creds,
      :playbook_path   => ManageIQ::Providers::IbmPowerVc::Engine.root.join("content/ansible_runner/run.yml"),
    }

    _log.info("execute image import playbook")
    ManageIQ::Providers::IbmPowerVc::CloudManager::PvcImageImportWorkflow.create_job({}, extra_vars, workflow_opts, [host], credentials, :poll_interval => 5.seconds, :timeout => wrkfl_timeout)
  end

  private_class_method def self.set_ssh_pkey_auth(dst_provider_id, pkey, unlock)
    powervs = ExtManagementSystem.find(dst_provider_id)
    powervs.create_ssh_pkey_auth(pkey, unlock)
  end

  private_class_method def self.set_import_auth(dst_provider_id, key, iv, encr_cos_creds)
    powervs = ExtManagementSystem.find(dst_provider_id)
    powervs.create_import_auth(key, iv, encr_cos_creds)
  end

  private_class_method def self.get_image_info(img_id)
    image = MiqTemplate.find(img_id)
    img_os = OperatingSystem.find_by(:vm_or_template => image.id)
    {:name => image.name, :os => img_os}
  end

  private_class_method def self.bucket_name(bucket_id)
    CloudObjectStoreContainer.find(bucket_id).name
  end

  private_class_method def self.cos_creds(provider_id)
    cos = ExtManagementSystem.find(provider_id)
    cos.cos_creds
  end

  private_class_method def self.encrypt_with_aes(creds)
    cipher = OpenSSL::Cipher.new('aes-256-cbc')
    cipher.encrypt

    key  = Base64.strict_encode64(cipher.random_key)
    iv   = Base64.strict_encode64(cipher.random_iv)
    encr = Base64.strict_encode64(cipher.update(creds.to_json) + cipher.final)

    [encr, key, iv]
  end

  private_class_method def self.image_ems_ref(bucket_id)
    MiqTemplate.find(bucket_id).uid_ems
  end
end
