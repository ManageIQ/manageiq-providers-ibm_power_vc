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

  def add_vms
    add_cloud_collection(:vms) do |builder|
      builder.add_default_values(:vendor => manager.class.vm_vendor)
      builder.add_properties(:custom_reconnect_block => power_hmc_reconnect_block)
    end
  end

  private

  def power_hmc_reconnect_block
    lambda do |inventory_collection, inventory_objects_index, attributes_index|
      relation = Vm.where(
        :ems_id => nil,
        :type => [
          "ManageIQ::Providers::IbmPowerHmc::InfraManager::Vios",
          "ManageIQ::Providers::IbmPowerVc::CloudManager::Vm"
        ]
      )

      return if relation.count <= 0

      inventory_objects_index.each_slice(100) do |batch|
        batch_refs = batch.map(&:first)
        relation.where(inventory_collection.manager_ref.first => batch_refs).order(:id => :asc).each do |record|
          index = inventory_collection.object_index_with_keys(inventory_collection.manager_ref_to_cols, record)

          # We need to delete the record from the inventory_objects_index
          # and attributes_index, otherwise it would be sent for create.
          inventory_object = inventory_objects_index.delete(index)
          hash             = attributes_index.delete(index)

          # Skip if hash is blank, which can happen when having several archived entities with the same ref
          next unless hash

          record.assign_attributes(hash.except(:id))
          if !inventory_collection.check_changed? || record.changed?
            record.save!
            inventory_collection.store_updated_records(record)
          end

          inventory_object.id = record.id
        end
      end
    end
  end
end
