describe ManageIQ::Providers::IbmPowerVc::CloudManager::Refresher do
  let(:zone) { EvmSpecHelper.create_guid_miq_server_zone.last }
  let(:ems) { FactoryBot.create(:ems_ibm_power_vc_with_vcr_authentication, :zone => zone) }

  describe "#refresh" do
    context "full refresh" do
      it "Performs a full refresh" do
        1.times do
          with_vcr { refresh(ems) }

          assert_ems
          assert_specific_availability_zone
          assert_specific_cloud_tenant
          assert_specific_flavor
          assert_specific_vm
        end
      end
    end

    def assert_ems
      expect(ems.last_refresh_error).to be_nil
      expect(ems.last_refresh_date).not_to be_nil

      expect(ems.availability_zones.count).to eq(3)
      expect(ems.cloud_tenants.count).to eq(1)
      expect(ems.flavors.count).to eq(12)
      expect(ems.vms.count).to eq(4)
    end

    def assert_specific_availability_zone
      az = ems.availability_zones.find_by(:ems_ref => "Default Group")
      expect(az).to have_attributes(
        :name                        => "Default Group",
        :ems_ref                     => "Default Group",
        :type                        => "ManageIQ::Providers::IbmPowerVc::CloudManager::AvailabilityZone",
        :provider_services_supported => ["compute"]
      )
    end

    def assert_specific_cloud_tenant
      cloud_tenant = ems.cloud_tenants.find_by(:ems_ref => "676b8977322946c0ab4700d7b908db5b")
      expect(cloud_tenant).to have_attributes(
        :name        => "ibm-default",
        :description => "IBM Default Tenant",
        :enabled     => true,
        :ems_ref     => "676b8977322946c0ab4700d7b908db5b",
        # TODO: :type        => "ManageIQ::Providers::IbmPowerVc::CloudManager::CloudTenant"
      )
    end

    def assert_specific_flavor
      flavor = ems.flavors.find_by(:ems_ref => "4c7b250adb349d84f638aec9c76f6eba")
      expect(flavor).to have_attributes(
        :name               => "4c7b250adb349d84f638aec9c76f6eba",
        :description        => "1 CPUs, 4 GB RAM, 100 GB Root Disk",
        :cpus               => 1,
        :cpu_cores          => nil,
        :memory             => 4.gigabytes,
        :ems_ref            => "4c7b250adb349d84f638aec9c76f6eba",
        :type               => "ManageIQ::Providers::IbmPowerVc::CloudManager::Flavor",
        :root_disk_size     => 100.gigabytes,
        :swap_disk_size     => 0,
        :publicly_available => false
      )
    end

    def assert_specific_vm
      vm = ems.vms.find_by(:ems_ref => "42420bf6-e08e-4360-85b0-4dea6e80344f")
      expect(vm).to have_attributes(
        :vendor            => "ibm",
        :name              => "RHEL82_100GB-test",
        :description       => nil,
        :location          => "unknown",
        :uid_ems           => "42420bf6-e08e-4360-85b0-4dea6e80344f",
        :connection_state  => "connected",
        :type              => "ManageIQ::Providers::IbmPowerVc::CloudManager::Vm",
        :ems_ref           => "42420bf6-e08e-4360-85b0-4dea6e80344f",
        :flavor            => ems.flavors.find_by(:ems_ref => "4c7b250adb349d84f638aec9c76f6eba"),
        :availability_zone => ems.availability_zones.find_by(:ems_ref => "Default Group"),
        :cloud             => true,
        :cloud_tenant      => ems.cloud_tenants.find_by(:ems_ref => "676b8977322946c0ab4700d7b908db5b"),
        :raw_power_state   => "ACTIVE",
        :power_state       => "on"
      )
    end

    def with_vcr(suffix = nil, &block)
      cassette_name = described_class.name.underscore
      cassette_name += "_#{suffix}" if suffix

      VCR.use_cassette(cassette_name, &block)
    end

    def refresh(targets)
      described_class.refresh(Array(targets))
    end
  end
end
