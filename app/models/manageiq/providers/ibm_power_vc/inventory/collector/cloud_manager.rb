class ManageIQ::Providers::IbmPowerVc::Inventory::Collector::CloudManager < ManageIQ::Providers::Openstack::Inventory::Collector::CloudManager
  def powervc_release
    @manager.powervc_release
  end
end