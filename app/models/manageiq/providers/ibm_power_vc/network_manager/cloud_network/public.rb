class ManageIQ::Providers::IbmPowerVc::NetworkManager::CloudNetwork::Public < ManageIQ::Providers::IbmPowerVc::NetworkManager::CloudNetwork
  def self.display_name(number = 1)
    n_('Cloud Network (IBM PowerVC)', 'Cloud Networks (IBM PowerVC)', number)
  end
end
