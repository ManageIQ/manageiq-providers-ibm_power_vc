class ManageIQ::Providers::IbmPowerVc::Inventory::Persister < ManageIQ::Providers::Openstack::Inventory::Persister
  require_nested :CloudManager
  require_nested :StorageManager

  def cinder_manager
    manager.kind_of?(ManageIQ::Providers::IbmPowerVc::StorageManager::CinderManager) ? manager : manager.cinder_manager
  end
end
