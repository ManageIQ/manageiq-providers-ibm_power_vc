class ManageIQ::Providers::IbmPowerVc::CloudManager::Refresher < ManageIQ::Providers::Openstack::CloudManager::Refresher
  def save_inventory(ems, target, inventory_collections)
    super
    # Queue refresh for each of our child HMCs if we are performing a full refresh
    EmsRefresh.queue_refresh(ems.ibm_power_hmcs.pluck(:type, :id)) if target.kind_of?(ManageIQ::Providers::BaseManager)
  end
end
