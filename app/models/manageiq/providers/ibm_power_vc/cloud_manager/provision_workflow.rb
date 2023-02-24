class ManageIQ::Providers::IbmPowerVc::CloudManager::ProvisionWorkflow < ManageIQ::Providers::Openstack::CloudManager::ProvisionWorkflow
  def self.provider_model
    ManageIQ::Providers::IbmPowerVc::CloudManager
  end
end
