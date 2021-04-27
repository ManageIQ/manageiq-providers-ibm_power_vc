ManageIQ::Providers::Openstack::NetworkManager.include(ActsAsStiLeafClass)

class ManageIQ::Providers::IbmPowerVc::NetworkManager < ManageIQ::Providers::Openstack::NetworkManager
  require_nested :EventCatcher

  def self.ems_type
    @ems_type ||= "ibm_power_vc_network".freeze
  end

  def self.description
    @description ||= "IBM PowerVC Network".freeze
  end
end
