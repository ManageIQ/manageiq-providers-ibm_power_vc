class ManageIQ::Providers::IbmPowerVc::NetworkManager::CloudNetwork::Public < ManageIQ::Providers::Openstack::NetworkManager::CloudNetwork::Public
  def self.display_name(number = 1)
    n_('External Cloud Network (IBM PowerVC)', 'External Cloud Networks (IBM PowerVC)', number)
  end
end
