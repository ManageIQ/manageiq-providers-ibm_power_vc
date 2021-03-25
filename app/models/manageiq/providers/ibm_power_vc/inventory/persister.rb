class ManageIQ::Providers::IbmPowerVc::Inventory::Persister < ManageIQ::Providers::Openstack::Inventory::Persister
  require_nested :CloudManager
end
