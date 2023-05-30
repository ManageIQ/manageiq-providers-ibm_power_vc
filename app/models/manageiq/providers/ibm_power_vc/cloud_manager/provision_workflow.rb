class ManageIQ::Providers::IbmPowerVc::CloudManager::ProvisionWorkflow < ManageIQ::Providers::Openstack::CloudManager::ProvisionWorkflow
  def self.provider_model
    ManageIQ::Providers::IbmPowerVc::CloudManager
  end

  private

  def dialog_name_from_automate(message = 'get_dialog_name', extra_attrs = {})
    extra_attrs['platform'] = 'ibm_power_vc'
    super(message, extra_attrs)
  end
end
