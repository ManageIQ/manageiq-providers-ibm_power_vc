if ENV['CI']
  require 'simplecov'
  SimpleCov.start
end

Dir[Rails.root.join("spec/shared/**/*.rb")].each { |f| require f }
Dir[File.join(__dir__, "support/**/*.rb")].each { |f| require f }

require "manageiq/providers/ibm_power_vc"

def sanitizer(interaction)
  # Remove internal network hostnames
  interaction.response.body.gsub!(/"host": "[^"]*?"/, '"host": "powervc.local"')
end

def fix_token_expires_at(interaction)
  data = JSON.parse(interaction.response.body)
  data["token"]["expires_at"] = "9999-12-31T23:59:59.999999Z"
  interaction.response.body = data.to_json.force_encoding('ASCII-8BIT')
end

VCR.configure do |config|
  config.ignore_hosts 'codeclimate.com' if ENV['CI']
  config.cassette_library_dir = File.join(ManageIQ::Providers::IbmPowerVc::Engine.root, 'spec/vcr_cassettes')

  config.before_record do |i|
    sanitizer(i)
    fix_token_expires_at(i) if i.request.uri.end_with?("v3/auth/tokens")
  end

  config.define_cassette_placeholder(Rails.application.secrets.ibm_power_vc_defaults[:hostname]) do
    Rails.application.secrets.ibm_power_vc[:hostname]
  end
  config.define_cassette_placeholder(Rails.application.secrets.ibm_power_vc_defaults[:user_id]) do
    Rails.application.secrets.ibm_power_vc[:user_id]
  end
  config.define_cassette_placeholder(Rails.application.secrets.ibm_power_vc_defaults[:password]) do
    Rails.application.secrets.ibm_power_vc[:password]
  end

  config.filter_sensitive_data('IBM_POWER_VC_AUTHORIZATION') do |interaction|
    interaction.request.headers['X-Auth-Token'].first if interaction.request.headers.key?('X-Auth-Token')
  end

  %w[X-Subject-Token X-Openstack-Request-Id X-Compute-Request-Id].each do |key|
    config.filter_sensitive_data('IBM_POWER_VC_AUTHORIZATION') do |interaction|
      interaction.response.headers[key].first if interaction.response.headers.key?(key)
    end
  end
end
