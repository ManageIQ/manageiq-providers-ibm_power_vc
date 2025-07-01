FactoryBot.define do
  factory :ems_ibm_power_vc, :class => "ManageIQ::Providers::IbmPowerVc::CloudManager", :parent => :ems_openstack

  factory :ems_ibm_power_vc_with_vcr_authentication, :parent => :ems_ibm_power_vc do
    hostname { VcrSecrets.ibm_power_vc.hostname }
    port { 5000 }
    api_version { "v3" }
    keystone_v3_domain_id { "default" }
    security_protocol { "ssl-no-validation" }

    after(:create) do |ems|
      user_id  = VcrSecrets.ibm_power_vc.user_id
      password = VcrSecrets.ibm_power_vc.password

      ems.authentications << FactoryBot.create(
        :authentication,
        :userid   => user_id,
        :password => password
      )
    end
  end
end
