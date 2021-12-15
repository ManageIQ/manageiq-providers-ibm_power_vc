class ManageIQ::Providers::IbmPowerVc::Inventory::Persister::CloudManager < ManageIQ::Providers::Openstack::Inventory::Persister::CloudManager
  def initialize_inventory_collections
    super
    add_advanced_settings
  end

  def add_advanced_settings
    add_collection(cloud, :vms_and_templates_advanced_settings) do |builder|
      builder.add_properties(
        :manager_ref                  => %i[resource name],
        :model_class                  => ::AdvancedSetting,
        :parent_inventory_collections => %i[vms]
      )
    end
  end
end
