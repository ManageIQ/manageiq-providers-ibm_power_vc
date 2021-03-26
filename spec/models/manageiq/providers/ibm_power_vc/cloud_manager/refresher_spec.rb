describe ManageIQ::Providers::IbmPowerVc::CloudManager::Refresher do
  let(:zone) { EvmSpecHelper.create_guid_miq_server_zone.last }
  let(:ems) { FactoryBot.create(:ems_ibm_power_vc_with_vcr_authentication, :zone => zone) }

  describe "#refresh" do
    context "full refresh" do
      it "Performs a full refresh" do
        1.times do
          with_vcr { refresh(ems) }

          assert_ems
        end
      end
    end

    def assert_ems
      expect(ems.last_refresh_error).to be_nil
      expect(ems.last_refresh_date).not_to be_nil
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
