ManageIQ::Providers::Openstack::NetworkManager.include(ActsAsStiLeafClass)

class ManageIQ::Providers::IbmPowerVc::NetworkManager < ManageIQ::Providers::Openstack::NetworkManager
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
