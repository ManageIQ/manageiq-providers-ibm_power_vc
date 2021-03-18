class ManageIQ::Providers::IbmPowerVc::Inventory::Collector < ManageIQ::Providers::Openstack::Inventory::Collector
  include ActsAsStiLeafClass
  require_nested :CloudManager
end
