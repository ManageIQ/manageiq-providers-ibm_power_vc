ManageIQ::Providers::Openstack::StorageManager::SwiftManager.include(ActsAsStiLeafClass)

class ManageIQ::Providers::IbmPowerVc::StorageManager::SwiftManager < ManageIQ::Providers::Openstack::StorageManager::SwiftManager
  class << self
    delegate :refresh_ems, :to => ManageIQ::Providers::IbmPowerVc::CloudManager
  end

  def self.ems_type
    @ems_type ||= "ibm_power_vc_swift".freeze
  end

  def self.description
    @description ||= "IBM PowerVC Swift".freeze
  end
end
