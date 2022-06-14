class ManageIQ::Providers::IbmPowerVc::NetworkManager::CloudNetwork::Private < ManageIQ::Providers::Openstack::NetworkManager::CloudNetwork::Public
  def self.display_name(number = 1)
    n_('Cloud Network (IBM PowerVC)', 'Cloud Networks (IBM PowerVC)', number)
  end
end
