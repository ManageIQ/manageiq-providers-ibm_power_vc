class ManageIQ::Providers::IbmPowerVc::Inventory::Parser < ManageIQ::Providers::Openstack::Inventory::Parser
  require_nested :CloudManager
end
