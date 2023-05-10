describe ManageIQ::Providers::IbmPowerVc::CloudManager::Refresher do
  let(:zone) { EvmSpecHelper.create_guid_miq_server_zone.last }
  let(:ems) { FactoryBot.create(:ems_ibm_power_vc_with_vcr_authentication, :zone => zone) }
  let(:tenantid) { 'c619880eed614ec382ca0326ad62753c' }
  let(:flavorid) { 'f7afb3c0a38781004f1f2aeef49a9a9c' }
  let(:instid) { 'c345615d-6cfa-4e5a-8844-fb0c92a8cda9' }
  let(:azone) { 'p8_pvm' }
  let(:imageid) { 'a426dcdc-0d22-40dd-945a-f46b4a77bdb0' }
  let(:networkid) { '48b48f3a-80da-4a37-a10e-4b3382f69100' }

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
          assert_cinder_manager
          assert_network_manager
        end
      end
    end

    def assert_ems
      expect(ems.last_refresh_error).to be_nil
      expect(ems.last_refresh_date).not_to be_nil

      expect(ems.cloud_tenants.count).to be > 0
      expect(ems.availability_zones.count).to be > 2
      expect(ems.flavors.count).to be > 2
      expect(ems.vms.count).to be > 1

      expect(ems.type).to eq("ManageIQ::Providers::IbmPowerVc::CloudManager")
    end

    def assert_specific_availability_zone
      az = ems.availability_zones.find_by(:ems_ref => azone)
      expect(az).to have_attributes(
        :name                        => azone,
        :ems_ref                     => azone,
        :type                        => "ManageIQ::Providers::IbmPowerVc::CloudManager::AvailabilityZone",
        :provider_services_supported => ["compute"]
      )
    end

    def assert_specific_cloud_tenant
      cloud_tenant = ems.cloud_tenants.find_by(:ems_ref => tenantid)
      expect(cloud_tenant).to have_attributes(
        :name        => "cloud-global",
        :description => "",
        :enabled     => true,
        :ems_ref     => tenantid,
        :type        => "ManageIQ::Providers::IbmPowerVc::CloudManager::CloudTenant"
      )
    end

    def assert_specific_flavor
      flavor = ems.flavors.find_by(:ems_ref => flavorid)
      expect(flavor).to have_attributes(
        :name                 => "f7afb3c0a38781004f1f2aeef49a9a9c",
        :cpu_total_cores      => 1,
        :cpu_cores_per_socket => nil,
        :memory               => 2_147_483_648,
        :ems_ref              => flavorid,
        :type                 => "ManageIQ::Providers::IbmPowerVc::CloudManager::Flavor",
        :ephemeral_disk_size  => 0,
        :ephemeral_disk_count => 0,
        :root_disk_size       => 21_474_836_480,
        :swap_disk_size       => 0,
        :publicly_available   => false,
        :cpu_sockets          => 1
      )
    end

    def assert_specific_vm
      vm = ems.vms.find_by(:ems_ref => instid)
      expect(vm).to have_attributes(
        :vendor           => "ibm_power_vc",
        :name             => "PerfCollectVM",
        :description      => nil,
        :location         => "unknown",
        :uid_ems          => instid,
        :connection_state => "connected",
        :type             => "ManageIQ::Providers::IbmPowerVc::CloudManager::Vm",
        :ems_ref          => instid,
        :flavor           => ems.flavors.find_by(:ems_ref => flavorid),
        :cloud            => true,
        :cloud_tenant     => ems.cloud_tenants.find_by(:ems_ref => tenantid),
        :raw_power_state  => "ACTIVE",
        :power_state      => "on"
      )
    end

    def assert_cinder_manager
      cinder_manager = ManageIQ::Providers::StorageManager.find_by(:parent_ems_id => ems.id)
      expect(cinder_manager.type).to eq("ManageIQ::Providers::IbmPowerVc::StorageManager::CinderManager")
    end

    def assert_network_manager
      network_manager = ManageIQ::Providers::NetworkManager.find_by(:parent_ems_id => ems.id)
      expect(network_manager.type).to eq("ManageIQ::Providers::IbmPowerVc::NetworkManager")
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
