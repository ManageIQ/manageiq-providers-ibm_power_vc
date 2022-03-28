ManageIQ::Providers::Openstack::NetworkManager.include(ActsAsStiLeafClass)

class ManageIQ::Providers::IbmPowerVc::NetworkManager < ManageIQ::Providers::Openstack::NetworkManager
  require_nested :CloudNetwork
  require_nested :CloudSubnet
  require_nested :EventCatcher
  require_nested :FloatingIP
  require_nested :NetworkPort
  require_nested :NetworkRouter
  require_nested :SecurityGroup

  def self.ems_type
    @ems_type ||= "ibm_power_vc_network".freeze
  end

  def self.description
    @description ||= "IBM PowerVC Network".freeze
  end

  def image_name
    "ibm_power_vc"
  end
end
