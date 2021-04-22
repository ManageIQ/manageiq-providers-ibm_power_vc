module ManageIQ
  module Providers
    module IbmPowerVc
      class Engine < ::Rails::Engine
        isolate_namespace ManageIQ::Providers::IbmPowerVc

        config.autoload_paths << root.join('lib').to_s

        initializer :append_secrets do |app|
          app.config.paths["config/secrets"] << root.join("config", "secrets.defaults.yml").to_s
          app.config.paths["config/secrets"] << root.join("config", "secrets.yml").to_s
        end

        def self.vmdb_plugin?
          true
        end

        def self.plugin_name
          _('Ibm Power Vc Provider')
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
