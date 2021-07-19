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
  require_nested :Refresher
  require_nested :RefreshWorker
  require_nested :Template
  require_nested :Vm

  supports :metrics

  def self.vm_vendor
    "ibm_power_vc"
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
                        :label      => "API Username",
                        :isRequired => true,
                        :validate   => [{:type => "required"}],
                      },
                      {
                        :component  => "password-field",
                        :id         => "authentications.default.password",
                        :name       => "authentications.default.password",
                        :label      => "API Password",
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
                    :component => "password-field",
                    :id        => "authentications.node.password",
                    :name      => "authentications.node.password",
                    :label     => _("PowerVC Server Password"),
                    :type      => "password",
                  },

                  {
                    :component => "password-field",
                    :id        => "authentications.node.options",
                    :name      => "authentications.node.options",
                    :label     => _("Resource File Path"),
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

  def endpoint
    endpoints.detect { |e| e.role == "default" }
  end

  def node_auth
    authentications.detect { |e| e.authtype == "node" }
  end

  def get_image_info(img_id)
    image = MiqTemplate.find(img_id)
    os = OperatingSystem.find_by(:vm_or_template => image.id)

    # XXX: do we need verification here?
    if os.distribution == 'rhel'
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
    false
  end

  def self.ems_type
    @ems_type ||= "ibm_power_vc".freeze
  end

  def self.description
    @description ||= "IBM PowerVC".freeze
  end
end
