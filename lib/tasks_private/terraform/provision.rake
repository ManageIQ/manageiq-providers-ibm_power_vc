require "json"
require 'yaml'
require 'logger'
require 'ruby-terraform'

namespace :provision do
  desc "check terraform is installed"
  task :check => :environment do
    system("command -v terraform > /dev/null") or raise("install terraform to provision powervc vm")
  end

  desc "provision a vm"
  task :apply => :check do
    cdir = ENV['cwd'] || Dir.pwd
    tdir = __dir__
    config = setup(cdir, tdir)
    plan(config)
    apply(cdir, tdir)
  end

  desc "delete a vm"
  task :destroy => :check do
    cdir = ENV['cwd'] || Dir.pwd
    tdir = __dir__
    config = setup(cdir, tdir)
    destroy(config)
  end

  def setup(cdir, tdir)
    config = YAML.safe_load(File.read(File.join(cdir, "config/secrets.yml")))
    ENV['PATH'] = "#{ENV['PATH']}:#{tdir}"
    Dir.chdir(tdir)

    log_file = File.open('ruby_terraform.log', 'a')
    RubyTerraform.configure do |tconfig|
      tconfig.stdout = log_file
      tconfig.stderr = log_file
    end
    RubyTerraform.init
    config
  end

  def plan(config)
    RubyTerraform.plan(
      :out          => 'terraform.tfplan',
      :var_file     => 'terraform.tfvars',
      :auto_approve => true,
      :vars         => {
        :openstack_auth_url  => URI::HTTPS.build(:host => config["test"]["ibm_power_vc"]["hostname"], :port => 5000, :path => "/v3").to_s,
        :openstack_user_name => config["test"]["ibm_power_vc"]["user_id"],
        :openstack_password  => config["test"]["ibm_power_vc"]["password"],
        :openstack_image     => config["test"]["ibm_power_vc"]["image"],
        :openstack_network   => config["test"]["ibm_power_vc"]["network"]
      }
    )
  end

  def apply(cdir, tdir)
    RubyTerraform.apply(
      :plan         => 'terraform.tfplan',
      :auto_approve => true
    )
    jfile = File.open(File.join(tdir, "terraform.tfstate"))
    data = JSON.parse(jfile.read)
    outfile = File.join(cdir, "spec/models/manageiq/providers/ibm_power_vc/cloud_manager/state.yml")
    File.write(outfile, data.to_yaml)
  end

  def destroy(config)
    RubyTerraform.destroy(
      :var_file     => 'terraform.tfvars',
      :auto_approve => true,
      :vars         => {
        :openstack_auth_url  => URI::HTTPS.build(:host => config["test"]["ibm_power_vc"]["hostname"], :port => 5000, :path => "/v3").to_s,
        :openstack_user_name => config["test"]["ibm_power_vc"]["user_id"],
        :openstack_password  => config["test"]["ibm_power_vc"]["password"],
        :openstack_image     => config["test"]["ibm_power_vc"]["image"],
        :openstack_network   => config["test"]["ibm_power_vc"]["network"],
      }
    )
  end
end
