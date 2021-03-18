class ManageIQ::Providers::IbmPowerVc::Inventory::Persister < ManageIQ::Providers::Openstack::Inventory::Persister
  include ActsAsStiLeafClass
  require_nested :CloudManager
end
