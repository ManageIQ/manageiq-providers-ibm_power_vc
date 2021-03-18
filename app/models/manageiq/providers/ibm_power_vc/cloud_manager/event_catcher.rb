class ManageIQ::Providers::IbmPowerVc::CloudManager::EventCatcher < ManageIQ::Providers::BaseManager::EventCatcher
  include ActsAsStiLeafClass

  require_nested :Runner

  def self.settings_name
    :event_catcher_ibm_power_vc
  end
end