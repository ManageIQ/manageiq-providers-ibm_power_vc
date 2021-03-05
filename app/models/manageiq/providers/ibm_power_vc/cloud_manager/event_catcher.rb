class ManageIQ::Providers::IbmPowerVc::CloudManager::EventCatcher < ManageIQ::Providers::BaseManager::EventCatcher
  require_nested :Runner

  def self.settings_name
    :event_catcher_ibm_power_vc
  end
end