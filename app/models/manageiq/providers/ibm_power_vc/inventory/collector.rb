class ManageIQ::Providers::IbmPowerVc::Inventory::Collector < ManageIQ::Providers::Openstack::Inventory::Collector
  require_nested :CloudManager
end
