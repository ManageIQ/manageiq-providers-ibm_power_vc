describe ManageIQ::Providers::IbmPowerVc::CloudManager::Refresher do
  let(:zone) { EvmSpecHelper.create_guid_miq_server_zone.last }
  let(:ems) { FactoryBot.create(:ems_ibm_power_vc_with_vcr_authentication, :zone => zone) }

  specs = YAML.load_file(File.join(__dir__, 'state.yml'))
  specs['resources'].each do |key, _value|
    case key['type']
    when 'openstack_compute_flavor_v2'
      let(:flavorid) { key['instances'][0]['attributes']['id'] }
    when 'openstack_identity_project_v3'
      let(:tenantid) { key['instances'][0]['attributes']['id'] }
    when 'openstack_compute_instance_v2'
      let(:instid) { key['instances'][0]['attributes']['id'] }
      let(:azone) { key['instances'][0]['attributes']['availability_zone'] }
    when 'openstack_images_image_v2'
      let(:imageid) { key['instances'][0]['attributes']['id'] }
    when 'openstack_networking_network_v2'
      let(:networkid) { key['instances'][0]['attributes']['id'] }
    end
  end

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

      expect(ems.cloud_tenants.count).to be > 1
      expect(ems.availability_zones.count).to be > 2
      expect(ems.flavors.count).to be > 2
      expect(ems.vms.count).to be > 1
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
        :name        => "ibm-default",
        :description => "IBM Default Tenant",
        :enabled     => true,
        :ems_ref     => tenantid
        # TODO: :type        => "ManageIQ::Providers::IbmPowerVc::CloudManager::CloudTenant"
      )
    end

    def assert_specific_flavor
      flavor = ems.flavors.find_by(:ems_ref => flavorid)
      expect(flavor).to have_attributes(
        :name                 => "small",
        :cpu_total_cores      => 2,
        :cpu_cores_per_socket => nil,
        :memory               => 8_589_934_592,
        :ems_ref              => flavorid,
        :type                 => "ManageIQ::Providers::IbmPowerVc::CloudManager::Flavor",
        :ephemeral_disk_size  => 0,
        :ephemeral_disk_count => 0,
        :root_disk_size       => 0,
        :swap_disk_size       => 0,
        :publicly_available   => true,
        :cpu_sockets          => 1
      )
    end

    def assert_specific_vm
      vm = ems.vms.find_by(:ems_ref => instid)
      expect(vm).to have_attributes(
        :vendor           => "ibm_power_vc",
        :name             => "miq-testvm",
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
