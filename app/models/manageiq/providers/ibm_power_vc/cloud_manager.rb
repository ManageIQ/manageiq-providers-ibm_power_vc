ManageIQ::Providers::Openstack::CloudManager.include(ActsAsStiLeafClass)

class ManageIQ::Providers::IbmPowerVc::CloudManager < ManageIQ::Providers::Openstack::CloudManager
  require_nested :AuthKeyPair
  require_nested :AvailabilityZone
  require_nested :AvailabilityZoneNull
  require_nested :CloudResourceQuota
  require_nested :CloudTenant
  require_nested :EventCatcher
  require_nested :Flavor
  require_nested :HostAggregate
  require_nested :MetricsCapture
  require_nested :MetricsCollectorWorker
  require_nested :PlacementGroup
  require_nested :Refresher
  require_nested :RefreshWorker
  require_nested :Snapshot
  require_nested :Template
  require_nested :Vm

  supports :create
  supports :metrics
  supports :native_console

  has_one :network_manager,
          :foreign_key => :parent_ems_id,
          :class_name  => "ManageIQ::Providers::IbmPowerVc::NetworkManager",
          :autosave    => true,
          :dependent   => :destroy

  has_one :cinder_manager,
          :foreign_key => :parent_ems_id,
          :class_name  => "ManageIQ::Providers::IbmPowerVc::StorageManager::CinderManager",
          :dependent   => :destroy,
          :inverse_of  => :parent_manager,
          :autosave    => true

  has_many :ssh_auths,
           :foreign_key => :resource_id,
           :class_name  => "ManageIQ::Providers::IbmPowerVc::CloudManager::PvcImageImportWorkflow::SshPkeyAuth",
           :autosave    => true,
           :dependent   => :destroy

  has_many :import_auths,
           :foreign_key => :resource_id,
           :class_name  => "ManageIQ::Providers::IbmPowerVc::CloudManager::PvcImageImportWorkflow::ImageImportAuth",
           :autosave    => true,
           :dependent   => :destroy

  def self.vm_vendor
    "ibm_power_vc"
  end

  def console_url
    "https://#{endpoint.hostname}"
  end

  def image_name
    "ibm_power_vc"
  end

  def self.params_for_create
    {
      :fields => [
        {
          :component    => "text-field",
          :id           => "provider_region",
          :name         => "provider_region",
          :label        => _("Provider Region"),
          :initialValue => _("RegionOne"),
        },
        {
          :component    => "select",
          :id           => "api_version",
          :name         => "api_version",
          :label        => _("API Version"),
          :initialValue => 'v3',
          :isRequired   => true,
          :hideField    => true,
          :validate     => [{:type => "required"}],
          :options      => [
            {
              :label => 'Keystone V3',
              :value => 'v3',
            },
          ],
        },
        {
          :component    => 'text-field',
          :id           => 'uid_ems',
          :name         => 'uid_ems',
          :label        => _('Domain ID'),
          :initialValue => 'default',
          :isRequired   => true,
          :condition    => {
            :when => 'api_version',
            :is   => 'v3',
          },
          :validate     => [{
            :type      => "required",
            :condition => {
              :when => 'api_version',
              :is   => 'v3',
            }
          }],
        },
        {
          :component => 'switch',
          :id        => 'tenant_mapping_enabled',
          :name      => 'tenant_mapping_enabled',
          :label     => _('Tenant Mapping Enabled'),
        },
        {
          :component => 'sub-form',
          :id        => 'endpoints-subform',
          :name      => 'endpoints-subform',
          :title     => _('Endpoints'),
          :fields    => [
            :component => 'tabs',
            :name      => 'tabs',
            :fields    => [
              {
                :component => 'tab-item',
                :id        => 'default-tab',
                :name      => 'default-tab',
                :title     => _('Default'),
                :fields    => [
                  {
                    :component              => 'validate-provider-credentials',
                    :id                     => 'authentications.default.valid',
                    :name                   => 'authentications.default.valid',
                    :skipSubmit             => true,
                    :isRequired             => true,
                    :validationDependencies => %w[name type api_version provider_region uid_ems],
                    :fields                 => [
                      {
                        :component    => "select",
                        :id           => "endpoints.default.security_protocol",
                        :name         => "endpoints.default.security_protocol",
                        :label        => _("Security Protocol"),
                        :isRequired   => true,
                        :initialValue => 'ssl-with-validation',
                        :validate     => [{:type => "required"}],
                        :options      => [
                          {
                            :label => _("SSL without validation"),
                            :value => "ssl-no-validation"
                          },
                          {
                            :label => _("SSL"),
                            :value => "ssl-with-validation"
                          },
                          {
                            :label => _("Non-SSL"),
                            :value => "non-ssl"
                          }
                        ]
                      },
                      {
                        :component  => "text-field",
                        :id         => "endpoints.default.hostname",
                        :name       => "endpoints.default.hostname",
                        :label      => _("PowerVC API Endpoint (Hostname or IPv4/IPv6 address)"),
                        :isRequired => true,
                        :validate   => [{:type => "required"}],
                      },
                      {
                        :component    => "text-field",
                        :id           => "endpoints.default.port",
                        :name         => "endpoints.default.port",
                        :label        => _("API Port"),
                        :type         => "number",
                        :initialValue => 5000,
                        :isRequired   => true,
                        :validate     => [{:type => "required"}],
                      },
                      {
                        :component  => "text-field",
                        :id         => "authentications.default.userid",
                        :name       => "authentications.default.userid",
                        :label      => _("API Username"),
                        :isRequired => true,
                        :validate   => [{:type => "required"}],
                      },
                      {
                        :component  => "password-field",
                        :id         => "authentications.default.password",
                        :name       => "authentications.default.password",
                        :label      => _("API Password"),
                        :type       => "password",
                        :isRequired => true,
                        :validate   => [{:type => "required"}],
                      },
                    ]
                  },
                ]
              },
              {
                :component => 'tab-item',
                :id        => 'events-tab',
                :name      => 'events-tab',
                :title     => _('Events'),
                :fields    => [
                  {
                    :component    => 'protocol-selector',
                    :id           => 'event_stream_selection',
                    :name         => 'event_stream_selection',
                    :skipSubmit   => true,
                    :initialValue => 'ceilometer',
                    :label        => _('Type'),
                    :options      => [
                      {
                        :label => _('Ceilometer'),
                        :value => 'ceilometer',
                      },
                      {
                        :label => _('STF'),
                        :value => 'stf',
                        :pivot => 'endpoints.stf.hostname',
                      },
                      {
                        :label => _('AMQP'),
                        :value => 'amqp',
                        :pivot => 'endpoints.amqp.hostname',
                      },
                    ],
                  },
                  {
                    :component    => 'text-field',
                    :hideField    => true,
                    :label        => 'ceilometer',
                    :id           => 'endpoints.ceilometer',
                    :name         => 'endpoints.ceilometer',
                    :initialValue => '',
                    :condition    => {
                      :when => 'event_stream_selection',
                      :is   => 'ceilometer',
                    },
                  },
                  {
                    :component              => 'validate-provider-credentials',
                    :id                     => 'endpoints.amqp.valid',
                    :name                   => 'endpoints.amqp.valid',
                    :skipSubmit             => true,
                    :isRequired             => true,
                    :validationDependencies => %w[type event_stream_selection],
                    :condition              => {
                      :when => 'event_stream_selection',
                      :is   => 'amqp',
                    },
                    :fields                 => [
                      {
                        :component  => "text-field",
                        :id         => "endpoints.amqp.hostname",
                        :name       => "endpoints.amqp.hostname",
                        :label      => _("Hostname (or IPv4 or IPv6 address)"),
                        :isRequired => true,
                        :validate   => [{:type => "required"}],
                      },
                      {
                        :component    => "text-field",
                        :id           => "endpoints.amqp.port",
                        :name         => "endpoints.amqp.port",
                        :label        => _("API Port"),
                        :type         => "number",
                        :isRequired   => true,
                        :initialValue => 5672,
                        :validate     => [{:type => "required"}],
                      },
                      {
                        :component  => "text-field",
                        :id         => "authentications.amqp.userid",
                        :name       => "authentications.amqp.userid",
                        :label      => "Username",
                        :isRequired => true,
                        :validate   => [{:type => "required"}],
                      },
                      {
                        :component  => "password-field",
                        :id         => "authentications.amqp.password",
                        :name       => "authentications.amqp.password",
                        :label      => "Password",
                        :type       => "password",
                        :isRequired => true,
                        :validate   => [{:type => "required"}],
                      },
                    ],
                  },
                  {
                    :component              => 'validate-provider-credentials',
                    :id                     => 'endpoints.stf.valid',
                    :name                   => 'endpoints.stf.valid',
                    :skipSubmit             => true,
                    :isRequired             => true,
                    :validationDependencies => %w[type event_stream_selection],
                    :condition              => {
                      :when => 'event_stream_selection',
                      :is   => 'stf',
                    },
                    :fields                 => [
                      {
                        :component    => "select",
                        :id           => "endpoints.stf.security_protocol",
                        :name         => "endpoints.stf.security_protocol",
                        :label        => _("Security Protocol"),
                        :isRequired   => true,
                        :initialValue => 'ssl-with-validation',
                        :validate     => [{:type => "required"}],
                        :options      => [
                          {
                            :label => _("SSL without validation"),
                            :value => "ssl-no-validation"
                          },
                          {
                            :label => _("SSL"),
                            :value => "ssl-with-validation"
                          },
                          {
                            :label => _("Non-SSL"),
                            :value => "non-ssl"
                          }
                        ]
                      },
                      {
                        :component  => "text-field",
                        :id         => "endpoints.stf.hostname",
                        :name       => "endpoints.stf.hostname",
                        :label      => _("Hostname (or IPv4 or IPv6 address)"),
                        :isRequired => true,
                        :validate   => [{:type => "required"}],
                      },
                      {
                        :component    => "text-field",
                        :id           => "endpoints.stf.port",
                        :name         => "endpoints.stf.port",
                        :label        => _("API Port"),
                        :type         => "number",
                        :isRequired   => true,
                        :initialValue => 5666,
                        :validate     => [{:type => "required"}],
                      },
                    ]
                  }
                ],
              },
              {
                :component => 'tab-item',
                :id        => 'ssh_keypair-tab',
                :name      => 'ssh_keypair-tab',
                :title     => _('RSA key pair'),
                :fields    => [
                  :component => 'provider-credentials',
                  :id        => 'endpoints.ssh_keypair.valid',
                  :name      => 'endpoints.ssh_keypair.valid',
                  :fields    => [
                    {
                      :component    => 'text-field',
                      :hideField    => true,
                      :label        => 'ssh_keypair',
                      :id           => 'endpoints.ssh_keypair',
                      :name         => 'endpoints.ssh_keypair',
                      :initialValue => '',
                      :condition    => {
                        :when       => 'authentications.ssh_keypair.userid',
                        :isNotEmpty => true,
                      },
                    },
                    {
                      :component => "text-field",
                      :id        => "authentications.ssh_keypair.userid",
                      :name      => "authentications.ssh_keypair.userid",
                      :label     => _("Username"),
                    },
                    {
                      :component      => "password-field",
                      :id             => "authentications.ssh_keypair.auth_key",
                      :name           => "authentications.ssh_keypair.auth_key",
                      :componentClass => 'textarea',
                      :rows           => 10,
                      :label          => _("Private Key"),
                    },
                  ],
                ],
              },
              {
                :component => 'tab-item',
                :id        => 'image_export-tab',
                :name      => 'image_export-tab',
                :title     => _('Image Export'),
                :fields    => [
                  {
                    :component => "text-field",
                    :id        => "authentications.node.userid",
                    :name      => "authentications.node.userid",
                    :label     => _("PowerVC Server Username"),
                  },
                  {
                    :component    => 'select',
                    :id           => 'authentications.node.options',
                    :name         => 'authentications.node.options',
                    :label        => _('Ansible Access Method'),
                    :initialValue => 'pkey',
                    :options      => [
                      {
                        :label => _('Private SSH Key'),
                        :value => 'pkey',
                      },
                      # FIXME: setting this to PKey only authentication until a fix to the appearing of
                      # FIXME: the password in Logs/DB is implemented
                      # {
                      #   :label => _('Password'),
                      #   :value => 'pass',
                      # },
                    ],
                  },
                  {
                    :component    => 'password-field',
                    :id           => 'authentications.node.auth_key_password',
                    :name         => 'authentications.node.auth_key_password',
                    :label        => _("PowerVC Server SSH Private Key Passphrase"),
                    :type         => "password",
                    :initialValue => '',
                    :condition    => {:when => 'authentications.node.options', :is => 'pkey'},
                  },
                  {
                    :component      => 'password-field',
                    :id             => 'authentications.node.auth_key',
                    :name           => 'authentications.node.auth_key',
                    :label          => _("PowerVC Server SSH Private Key"),
                    :type           => "password",
                    :initialValue   => '',
                    :componentClass => 'textarea',
                    :rows           => 10,
                    :condition      => {:when => 'authentications.node.options', :is => 'pkey'},
                  },
                  {
                    :component    => "password-field",
                    :id           => "authentications.node.password",
                    :name         => "authentications.node.password",
                    :label        => _("PowerVC Server SSH Password"),
                    :type         => "password",
                    :initialValue => '',
                    :condition    => {:when => 'authentications.node.options', :is => 'pass'},
                  },
                  {
                    :component => "text-field",
                    :id        => "endpoints.node.options",
                    :name      => "endpoints.node.options",
                    :label     => _("Resource File Path"),
                    :hideField => true,
                    :type      => "text",
                  },
                ]
              }
            ],
          ],
        },
      ]
    }
  end

  def endpoint(type = :default)
    case type
    when :default
      default_endpoint
    when :node
      endpoints.detect { |e| e.role == "node" }
    end
  end

  def node_auth
    authentications.detect { |e| e.authtype == "node" }
  end

  def get_image_info(img_id)
    image = MiqTemplate.find(img_id)
    os = OperatingSystem.find_by(:vm_or_template => image.id)
    {:name => image.name, :os => os.distribution}
  end

  def connect(options = {})
    super(options)
    # TODO: here allow getting saved creds
  end

  def ensure_swift_manager
    false
  end

  def self.ems_type
    @ems_type ||= "ibm_power_vc".freeze
  end

  def self.description
    @description ||= "IBM PowerVC".freeze
  end

  def required_credential_fields(type)
    case type.to_s
    when 'ssh_keypair' then [:userid, :auth_key]
    when 'node' then [:userid]
    else [:userid, :password]
    end
  end

  def authentication_status_ok?(type = nil)
    return true if [:ssh_keypair, :node].include?(type)

    super
  end

  def authentications_to_validate
    authentication_for_providers.collect(&:authentication_type) - [:ssh_keypair, :node]
  end

  def verify_credentials(auth_type = nil, options = {})
    self.class.verify_pvc_rel(endpoint[:hostname]) if auth_type == :default
    super
  end

  def self.verify_credentials(args)
    verify_pvc_rel(args.dig('endpoints', 'default', 'hostname'))
    super
  end

  def create_ssh_pkey_auth(pkey, unlock)
    ssh_auths.create!(:auth_key => pkey, :auth_key_password => unlock).id
  end

  def create_import_auth(key, iv, creds)
    import_auths.create!(:auth_key => key, :auth_key_password => iv, :password => creds).id
  end

  def remove_import_auth(id)
    import_auths.destroy(id)
  end

  def remove_ssh_auth(id)
    ssh_auths.destroy(id)
  end

  def self.powervc_release(host)
    require 'ethon'
    ethon = Ethon::Easy.new
    ethon.http_request("#{host}/powervc/version", :get, :followlocation => true, :ssl_verifyhost => 0, :ssl_verifypeer => 0)
    ethon.perform

    raise MiqException::MiqCommunicationsError, _('unable to retrieve IBM PowerVC release version number') if ethon.response_code != 200

    version = JSON.parse(ethon.response_body)['version']
    raise MiqException::MiqIncompleteData, _('unable to determine IBM PowerVC release version number') if version.blank?

    version
  end

  def self.verify_pvc_rel(host)
    min = ::Settings.ems&.ems_ibm_power_vc&.min_supported_rel&.to_s

    unless min.blank? || min.to_s == '0'
      rel = powervc_release(host)
      raise MiqException::ServiceNotAvailable, _("Unsupported PowerVC version '#{rel}', minimal requirement is >= '#{min}'") unless rel_supported?(min, rel)
    end
  end

  def self.rel_supported?(min, rel)
    raise MiqException::Error, _("value of min. supported PowerVC release is malformed") unless /^(\d+\.?)+$/.match?(min)
    raise MiqException::Error, _("value of provided PowerVC release is malformed: '#{rel}'") unless /^(\d+\.?)+$/.match?(rel)

    min_parsed = min.split('.')
    rel_parsed = rel.split('.')

    min_parsed.each_with_index do |a, i|
      break true  if a.to_i < rel_parsed[i].to_i
      break false if a.to_i > rel_parsed[i].to_i
    end != false
  end
end
