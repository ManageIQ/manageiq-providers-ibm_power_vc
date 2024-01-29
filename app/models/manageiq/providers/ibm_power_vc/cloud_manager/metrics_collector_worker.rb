class ManageIQ::Providers::IbmPowerVc::CloudManager::MetricsCollectorWorker < ManageIQ::Providers::BaseManager::MetricsCollectorWorker
  self.default_queue_name = "ibm_power_vc"

  def friendly_name
    @friendly_name ||= "C&U Metrics Collector for ManageIQ::Providers::IbmPowerVc"
  end
end
