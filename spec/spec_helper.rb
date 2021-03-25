if ENV['CI']
  require 'simplecov'
  SimpleCov.start
end

Dir[Rails.root.join("spec/shared/**/*.rb")].each { |f| require f }
Dir[File.join(__dir__, "support/**/*.rb")].each { |f| require f }

require "manageiq-providers-ibm_power_vc"

VCR.configure do |config|
  config.ignore_hosts 'codeclimate.com' if ENV['CI']
  config.cassette_library_dir = File.join(ManageIQ::Providers::IbmPowerVc::Engine.root, 'spec/vcr_cassettes')

  config.define_cassette_placeholder(Rails.application.secrets.ibm_power_vc_defaults[:user_id]) do
    Rails.application.secrets.ibm_power_vc[:user_id]
  end
  config.define_cassette_placeholder(Rails.application.secrets.ibm_power_vc_defaults[:password]) do
    Rails.application.secrets.ibm_power_vc[:password]
  end
end
