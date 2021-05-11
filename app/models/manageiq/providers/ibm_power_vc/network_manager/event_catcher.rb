ManageIQ::Providers::Openstack::NetworkManager::EventCatcher.include(ActsAsStiLeafClass)

class ManageIQ::Providers::IbmPowerVc::NetworkManager::EventCatcher < ManageIQ::Providers::Openstack::NetworkManager::EventCatcher
  require_nested :Runner

  def self.settings_name
    :event_catcher_ibm_power_vc_network
  end
end
