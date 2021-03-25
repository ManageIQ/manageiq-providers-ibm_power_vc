FactoryBot.define do
  factory :ems_ibm_power_vc, :class => "ManageIQ::Providers::IbmPowerVc::CloudManager", :parent => :ems_openstack

  factory :ems_ibm_power_vc_with_vcr_authentication, :parent => :ems_ibm_power_vc do
    hostname { Rails.application.secrets.ibm_power_vc[:hostname] }

    after(:create) do |ems|
      user_id  = Rails.application.secrets.ibm_power_vc[:user_id]
      password = Rails.application.secrets.ibm_power_vc[:password]

      ems.authentications << FactoryBot.create(
        :authentication,
        :userid   => user_id,
        :password => password
      )
    end
  end
end
