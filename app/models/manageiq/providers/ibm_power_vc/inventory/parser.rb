class ManageIQ::Providers::IbmPowerVc::Inventory::Parser < ManageIQ::Providers::Openstack::Inventory::Parser
  include ActsAsStiLeafClass
  require_nested :CloudManager
end
