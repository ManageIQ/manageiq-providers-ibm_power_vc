class ManageIQ::Providers::IbmPowerVc::Inventory::Parser::CloudManager < ManageIQ::Providers::Openstack::Inventory::Parser::CloudManager
  def parse_vm(vm, hosts)
    super
    server = persister.vms.find_or_build(vm.id.to_s)

    persister.vms_and_templates_advanced_settings.build(
      :resource     => server,
      :display_name => N_('Operating system'),
      :name         => 'operating_system',
      :value        => vm.attributes['operating_system'].to_s,
      :read_only    => true
    )

    persister.vms_and_templates_advanced_settings.build(
      :resource     => server,
      :display_name => N_('Power state'),
      :name         => 'power_state',
      :value        => vm.attributes[:os_ext_sts_power_state].to_s,
      :read_only    => true
    )

    persister.vms_and_templates_advanced_settings.build(
      :resource     => server,
      :display_name => N_('Task state'),
      :name         => 'task_state',
      :value        => vm.attributes[:os_ext_sts_task_state].to_s,
      :read_only    => true
    )

    persister.vms_and_templates_advanced_settings.build(
      :resource     => server,
      :display_name => N_('Secure boot'),
      :name         => 'secure_boot',
      :value        => get_secure_boot(vm.attributes['secure_boot']),
      :read_only    => true
    )

    persister.vms_and_templates_advanced_settings.build(
      :resource     => server,
      :display_name => N_('Pin state'),
      :name         => 'pin_policy',
      :value        => calculate_pinning(vm),
      :read_only    => true
    )

    persister.vms_and_templates_advanced_settings.build(
      :resource     => server,
      :display_name => N_('Memory (MB)'),
      :name         => 'memory',
      :value        => vm.attributes['memory_mb'].to_s,
      :max          => vm.attributes['max_memory_mb'].to_s,
      :min          => vm.attributes['min_memory_mb'].to_s,
      :read_only    => true
    )

    persister.vms_and_templates_advanced_settings.build(
      :resource     => server,
      :display_name => N_('Availability priority'),
      :name         => 'avail_priority',
      :value        => vm.attributes['avail_priority'].to_s,
      :read_only    => true
    )

    persister.vms_and_templates_advanced_settings.build(
      :resource     => server,
      :display_name => N_('Processors'),
      :name         => 'entitled_processors',
      :min          => vm.attributes['min_cpus'].to_s,
      :max          => vm.attributes['max_cpus'].to_s,
      :value        => vm.attributes['cpus'].to_s,
      :read_only    => true
    )

    persister.vms_and_templates_advanced_settings.build(
      :resource     => server,
      :display_name => N_('Processor mode'),
      :name         => 'vcpu_mode',
      :value        => vm.attributes['vcpu_mode'].to_s,
      :read_only    => true
    )

    persister.vms_and_templates_advanced_settings.build(
      :resource     => server,
      :display_name => N_('Processing units'),
      :name         => 'processing_units',
      :value        => vm.attributes['vcpus'].to_s,
      :min          => vm.attributes['min_vcpus'].to_s,
      :max          => vm.attributes['max_vcpus'].to_s,
      :read_only    => true
    )

    persister.vms_and_templates_advanced_settings.build(
      :resource     => server,
      :display_name => N_('Sharing mode'),
      :name         => 'dedicated_sharing_mode',
      :value        => vm.attributes['dedicated_sharing_mode'].to_s,
      :read_only    => true
    )

    persister.vms_and_templates_advanced_settings.build(
      :resource     => server,
      :display_name => N_('processor_type'),
      :name         => 'processor_type',
      :value        => vm.attributes['dedicated_sharing_mode'].to_s + vm.attributes['vcpu_mode'].to_s,
      :read_only    => true
    )

    persister.vms_and_templates_advanced_settings.build(
      :resource     => server,
      :display_name => N_('Shared weight'),
      :name         => 'shared_weight',
      :value        => vm.attributes['shared_weight'].to_s,
      :read_only    => true
    )

    persister.vms_and_templates_advanced_settings.build(
      :resource     => server,
      :display_name => N_('Shared processor pool'),
      :name         => 'shared_proc_pool_name',
      :value        => vm.attributes['shared_proc_pool_name'].to_s,
      :read_only    => true
    )

    persister.vms_and_templates_advanced_settings.build(
      :resource     => server,
      :display_name => N_('Processor compatibility mode'),
      :name         => 'current_compatibility_mode',
      :value        => vm.attributes['current_compatibility_mode'].to_s,
      :read_only    => true
    )

    persister.vms_and_templates_advanced_settings.build(
      :resource     => server,
      :display_name => N_('Desired compatibility mode'),
      :name         => 'desired_compatibility_mode',
      :value        => vm.attributes['desired_compatibility_mode'].to_s,
      :read_only    => true
    )

    persister.vms_and_templates_advanced_settings.build(
      :resource     => server,
      :display_name => N_('Physical Page Table ratio'),
      :name         => 'ppt_ratio',
      :value        => vm.attributes['ppt_ratio'].to_s,
      :read_only    => true
    )

    persister.vms_and_templates_advanced_settings.build(
      :resource     => server,
      :display_name => N_('Endianness'),
      :name         => 'endianness',
      :value        => vm.attributes['endianness'].to_s,
      :read_only    => true
    )

    persister.vms_and_templates_advanced_settings.build(
      :resource     => server,
      :display_name => N_('AME Expansion Factor'),
      :name         => 'ame_expansion_factor',
      :value        => get_ame_factor(vm.attributes["ame_expansion_factor"].to_s),
      :read_only    => true
    )

    persister.vms_and_templates_advanced_settings.build(
      :resource     => server,
      :display_name => N_('Enforce Affinity Check'),
      :name         => 'enforce_affinity_check',
      :value        => get_affinity_check(vm),
      :read_only    => true
    )

    persister.vms_and_templates_advanced_settings.build(
      :resource     => server,
      :display_name => N_('Simplified Remote Restart Capability'),
      :name         => 'srr_capability',
      :value        => vm.attributes['srr_capability'].to_s,
      :read_only    => true
    )

    persister.vms_and_templates_advanced_settings.build(
      :resource     => server,
      :display_name => N_('Simplified Remote Restart State'),
      :name         => 'srr_state',
      :value        => vm.attributes['srr_state'].to_s,
      :read_only    => true
    )
  end

  def get_ame_factor(ame_input)
    ame_input.nil? || ame_input == "0.0" ? "disabled" : ame_input
  end

  def get_secure_boot(secure_boot_input)
    case secure_boot_input
    when "0"
      "disabled"
    when "1"
      "log only"
    when "2"
      "enforce"
    else
      ""
    end
  end

  def get_affinity_check(vm)
    vm.metadata.each do |item|
      return item.value if item.key == "enforce_affinity_check"
    end
    ""
  end

  def calculate_pinning(vm)
    pin_vm = "false"
    move_pin_vm = "false"
    vm.metadata.each do |item|
      case item.key
      when "pin_vm"
        pin_vm = item.value
      when "move_pin_vm"
        move_pin_vm = item.value
      end
    end

    if pin_vm && !move_pin_vm
      "hard"
    elsif pin_vm && move_pin_vm
      "soft"
    else
      "none"
    end
  end
end
