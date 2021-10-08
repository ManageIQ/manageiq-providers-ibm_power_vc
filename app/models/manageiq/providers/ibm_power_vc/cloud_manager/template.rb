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

    extra_vars = {}
    credentials = []
    hosts = []

    _, _, region, _, access_key, secret_key = cos_creds(options['obj_storage_id'])
    diskType = CloudVolumeType.find(options['disk_type_id']).name

    # FIXME: pass creds by ids instead of by value
    cos_pvs_creds = {:region => region, :bucketName => bucket_name(options['bucket_id']), :accessKey => access_key, :secretKey => secret_key}

    workflow_opts = {
      :session_id      => session_id,
      :ems_id          => ext_management_system.id,
      :src_provider_id => options['src_provider_id'].to_i,
      :miq_img         => get_image_info(options['src_image_id']),
      :keep_ova        => options['keep_ova'],
      :cos_pvs_creds   => cos_pvs_creds,
      :playbook_path   => ManageIQ::Providers::IbmPowerVc::Engine.root.join("content/ansible_runner/run.yml"),
    }

    _log.info("execute image import playbook")
    job = ManageIQ::Providers::IbmPowerVc::CloudManager::PvcImageImportWorkflow.create_job({}, extra_vars, workflow_opts, hosts, credentials, :poll_interval => 5.seconds)
    job.signal(:start)
  end

  private_class_method def self.get_image_info(img_id)
    image = MiqTemplate.find(img_id)
    os = OperatingSystem.find_by(:vm_or_template => image.id)
    {:uid_ems => image.name}
  end

  private_class_method def self.bucket_name(bucket_id)
    CloudObjectStoreContainer.find(bucket_id).name
  end

  private_class_method def self.cos_creds(provider_id)
    cos = ExtManagementSystem.find(provider_id)
    cos.cos_creds
  end
end
