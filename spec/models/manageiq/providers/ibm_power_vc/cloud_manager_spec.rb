describe ManageIQ::Providers::IbmPowerVc::CloudManager do
  describe "#ibm_power_hmcs association" do
    let(:zone) { EvmSpecHelper.create_guid_miq_server_zone.last }
    let!(:power_vc) { FactoryBot.create(:ems_ibm_power_vc, :name => "PowerVC Manager", :zone => zone) }

    context "with no associated HMCs" do
      it "returns an empty collection" do
        expect(power_vc.ibm_power_hmcs).to be_empty
      end
    end

    context "with associated HMCs" do
      let!(:hmc1) { FactoryBot.create(:ems_ibm_power_hmc_infra, :name => "HMC 1", :parent_ems_id => power_vc.id, :zone => zone) }
      let!(:hmc2) { FactoryBot.create(:ems_ibm_power_hmc_infra, :name => "HMC 2", :parent_ems_id => power_vc.id, :zone => zone) }
      let!(:hmc3) { FactoryBot.create(:ems_ibm_power_hmc_infra, :name => "HMC 3", :zone => zone) }

      it "returns all HMCs associated with the PowerVC manager" do
        expect(power_vc.ibm_power_hmcs).to contain_exactly(hmc1, hmc2)
      end

      it "does not include HMCs without a parent relationship" do
        expect(power_vc.ibm_power_hmcs).not_to include(hmc3)
      end

      it "returns the correct count of associated HMCs" do
        expect(power_vc.ibm_power_hmcs.count).to eq(2)
      end

      it "allows accessing HMC properties through the association" do
        hmc_names = power_vc.ibm_power_hmcs.pluck(:name)
        expect(hmc_names).to contain_exactly("HMC 1", "HMC 2")
      end
    end

    context "when PowerVC manager is destroyed" do
      let!(:hmc1) { FactoryBot.create(:ems_ibm_power_hmc_infra, :name => "HMC 1", :parent_ems_id => power_vc.id, :zone => zone) }
      let!(:hmc2) { FactoryBot.create(:ems_ibm_power_hmc_infra, :name => "HMC 2", :parent_ems_id => power_vc.id, :zone => zone) }

      it "nullifies the parent_ems_id on associated HMCs (dependent: :nullify)" do
        expect(hmc1.parent_ems_id).to eq(power_vc.id)
        expect(hmc2.parent_ems_id).to eq(power_vc.id)

        power_vc.destroy

        hmc1.reload
        hmc2.reload

        expect(hmc1.parent_ems_id).to be_nil
        expect(hmc2.parent_ems_id).to be_nil
      end

      it "does not destroy the associated HMCs" do
        hmc1_id = hmc1.id
        hmc2_id = hmc2.id

        power_vc.destroy

        expect(ManageIQ::Providers::IbmPowerHmc::InfraManager.exists?(hmc1_id)).to be true
        expect(ManageIQ::Providers::IbmPowerHmc::InfraManager.exists?(hmc2_id)).to be true
      end
    end

    context "with multiple PowerVC managers" do
      let!(:power_vc2) { FactoryBot.create(:ems_ibm_power_vc, :name => "PowerVC Manager 2", :zone => zone) }
      let!(:hmc1) { FactoryBot.create(:ems_ibm_power_hmc_infra, :name => "HMC 1", :parent_ems_id => power_vc.id, :zone => zone) }
      let!(:hmc2) { FactoryBot.create(:ems_ibm_power_hmc_infra, :name => "HMC 2", :parent_ems_id => power_vc2.id, :zone => zone) }

      it "correctly associates HMCs with their respective PowerVC managers" do
        expect(power_vc.ibm_power_hmcs).to contain_exactly(hmc1)
        expect(power_vc2.ibm_power_hmcs).to contain_exactly(hmc2)
      end
    end
  end
end
