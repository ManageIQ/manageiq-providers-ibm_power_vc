class ManageIQ::Providers::IbmPowerVc::Inventory < ManageIQ::Providers::Openstack::Inventory
  def self.parser_classes_for(_ems, target)
    case target
    when InventoryRefresh::TargetCollection
      [ManageIQ::Providers::IbmPowerVc::Inventory::Parser::CloudManager,
       ManageIQ::Providers::IbmPowerVc::Inventory::Parser::NetworkManager,
       ManageIQ::Providers::IbmPowerVc::Inventory::Parser::StorageManager::CinderManager]
    else
      super
    end
  end
end
