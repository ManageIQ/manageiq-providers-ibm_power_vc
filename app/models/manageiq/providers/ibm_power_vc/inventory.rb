class ManageIQ::Providers::IbmPowerVc::Inventory < ManageIQ::Providers::Openstack::Inventory
  require_nested :Parser
  require_nested :Persister
end
