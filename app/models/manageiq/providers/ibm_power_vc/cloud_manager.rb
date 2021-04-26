ManageIQ::Providers::Openstack::CloudManager.include(ActsAsStiLeafClass)

class ManageIQ::Providers::IbmPowerVc::CloudManager < ManageIQ::Providers::Openstack::CloudManager
  require_nested :AuthKeyPair
  require_nested :AvailabilityZone
  require_nested :AvailabilityZoneNull
  require_nested :CloudResourceQuota
  require_nested :CloudTenant
  require_nested :Flavor
  require_nested :HostAggregate
  require_nested :MetricsCapture
  require_nested :MetricsCollectorWorker
  require_nested :Refresher
  require_nested :RefreshWorker
  require_nested :Template
  require_nested :Vm

  def self.vm_vendor
    "ibm"
  end

  def image_name
    "power_vc"
  end

  def self.params_for_create
    params = super

    params[:fields].push(
      {
        :component => "text-field",
        :id        => "endpoints.node.url",
        :name      => "endpoints.node.url",
        :label     => _("PowerVC Node Location"),
      },

      {
        :component => "text-field",
        :id        => "authentications.node.userid",
        :name      => "authentications.node.userid",
        :label     => _("PowerVC Node Username"),
      },

      {
        :component => "password-field",
        :id        => "authentications.node.password",
        :name      => "authentications.node.password",
        :label     => _("PowerVC Node Password"),
        :type      => "password",
      },
    )

    params
  end

  def node_endp
    endpoints.detect { |e| e.role == "node" }
  end

  def node_auth
    authentications.detect { |e| e.authtype == "node" }
  end

  def get_image_info(uid_ems)
    image = MiqTemplate.find_by(:uid_ems => uid_ems)
    os = OperatingSystem.find_by(:vm_or_template => image.id)

    # XXX: do we need verification here?
    if(os.distribution == 'rhel')
      os.distribution = 'redhat'
    end

    {:name => image.name, :os => os.distribution}
  end

  def connect(options = {})
    super(options)
    # TODO: here allow getting saved creds
  end

  def ensure_network_manager
    build_network_manager(:type => 'ManageIQ::Providers::IbmPowerVc::NetworkManager') unless network_manager
  end

  def ensure_cinder_manager
    return false if cinder_manager
    build_cinder_manager(:type => 'ManageIQ::Providers::IbmPowerVc::StorageManager::CinderManager')
    true
  end

  def ensure_swift_manager
    return false if swift_manager
    build_swift_manager(:type => 'ManageIQ::Providers::IbmPowerVc::StorageManager::SwiftManager')
    true
  end

  def self.ems_type
    @ems_type ||= "ibm_power_vc".freeze
  end

  def self.description
    @description ||= "IBM PowerVC".freeze
  end
end
