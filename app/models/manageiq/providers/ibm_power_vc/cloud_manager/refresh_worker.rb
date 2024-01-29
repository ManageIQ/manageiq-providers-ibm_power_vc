class ManageIQ::Providers::IbmPowerVc::CloudManager::RefreshWorker < ManageIQ::Providers::BaseManager::RefreshWorker
  def self.settings_name
    :ems_refresh_worker_ibm_power_vc
  end
end
