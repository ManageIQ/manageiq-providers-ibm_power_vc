class ManageIQ::Providers::IbmPowerVc::Inventory::Parser < ManageIQ::Providers::Openstack::Inventory::Parser
  require_nested :CloudManager
  require_nested :NetworkManager
  require_nested :StorageManager
end
