ManageIQ::Providers::Openstack::CloudManager::Template.include(ActsAsStiLeafClass)

class ManageIQ::Providers::IbmPowerVc::CloudManager::Template < ManageIQ::Providers::Openstack::CloudManager::Template
  has_and_belongs_to_many :cloud_tenants,
                          :foreign_key             => "vm_id",
                          :join_table              => "cloud_tenants_vms",
                          :association_foreign_key => "cloud_tenant_id",
                          :class_name              => "ManageIQ::Providers::IbmPowerVc::CloudManager::CloudTenant"
end
