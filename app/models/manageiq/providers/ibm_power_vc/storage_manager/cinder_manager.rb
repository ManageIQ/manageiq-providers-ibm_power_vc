ManageIQ::Providers::Openstack::StorageManager::CinderManager.include(ActsAsStiLeafClass)

class ManageIQ::Providers::IbmPowerVc::StorageManager::CinderManager < ManageIQ::Providers::Openstack::StorageManager::CinderManager
  class << self
    delegate :refresh_ems, :to => ManageIQ::Providers::IbmPowerVc::CloudManager
  end

  def self.ems_type
    @ems_type ||= "ibm_power_vc_cinder".freeze
  end

  def self.description
    @description ||= "IBM PowerVC Cinder".freeze
  end
end
