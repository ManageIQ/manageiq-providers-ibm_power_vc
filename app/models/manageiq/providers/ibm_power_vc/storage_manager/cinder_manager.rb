ManageIQ::Providers::Openstack::StorageManager::CinderManager.include(ActsAsStiLeafClass)

class ManageIQ::Providers::IbmPowerVc::StorageManager::CinderManager < ManageIQ::Providers::Openstack::StorageManager::CinderManager
  require_nested :EventCatcher
  require_nested :CloudVolume
  require_nested :CloudVolumeBackup
  require_nested :CloudVolumeSnapshot
  require_nested :CloudVolumeType

  def self.ems_type
    @ems_type ||= "ibm_power_vc_cinder".freeze
  end

  def self.description
    @description ||= "IBM PowerVC Cinder".freeze
  end
end
