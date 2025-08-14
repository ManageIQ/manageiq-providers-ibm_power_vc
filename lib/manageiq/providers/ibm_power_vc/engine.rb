module ManageIQ
  module Providers
    module IbmPowerVc
      class Engine < ::Rails::Engine
        isolate_namespace ManageIQ::Providers::IbmPowerVc

        config.autoload_paths << root.join('lib')

        def self.vmdb_plugin?
          true
        end

        def self.plugin_name
          _('IBM PowerVC Provider')
        end

        def self.init_loggers
          $ibm_power_vc_log ||= Vmdb::Loggers.create_logger("ibm_power_vc.log")
        end

        def self.apply_logger_config(config)
          Vmdb::Loggers.apply_config_value(config, $ibm_power_vc_log, :level_ibm_power_vc)
        end
      end
    end
  end
end
