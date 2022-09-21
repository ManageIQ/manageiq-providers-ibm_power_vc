FactoryBot.define do
  factory :vm_ibm_power_vc, :class => "ManageIQ::Providers::IbmPowerVc::CloudManager::Vm", :parent => :vm_cloud do
    vendor { "ibm_power_vc" }

    trait :with_provider do
      after(:create) do |x|
        FactoryBot.create(:ems_ibm_cloud_power_virtual_servers_cloud, :vms => [x])
      end
    end
  end
end
