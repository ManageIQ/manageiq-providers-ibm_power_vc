ManageIQ::Providers::Openstack::StorageManager::CinderManager.include(ActsAsStiLeafClass)

class ManageIQ::Providers::IbmPowerVc::StorageManager::CinderManager < ManageIQ::Providers::Openstack::StorageManager::CinderManager
  require_nested :EventCatcher

  def self.ems_type
    @ems_type ||= "ibm_power_vc_cinder".freeze
  end

  def self.description
    @description ||= "IBM PowerVC Cinder".freeze
  end
end
