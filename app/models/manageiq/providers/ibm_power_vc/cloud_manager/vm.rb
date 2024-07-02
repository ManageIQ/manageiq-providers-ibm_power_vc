ManageIQ::Providers::Openstack::CloudManager::Vm.include(ActsAsStiLeafClass)

class ManageIQ::Providers::IbmPowerVc::CloudManager::Vm < ManageIQ::Providers::Openstack::CloudManager::Vm
  supports :html5_console do
    if current_state != "on"
      _("VM Console not supported because VM is not powered on")
    elsif orphaned?
      _("VM Console not supported because VM is orphaned")
    elsif archived?
      _("VM Console not supported because VM is archived")
    end
  end
  supports :launch_html5_console

  def remote_console_acquire_ticket(_userid, _originating_server, _console_type)
    super
  rescue => err
    msg = err.response.reason_phrase == 'Not Implemented' ? 'PowerVM NovaLink is required for VM console access.' : err.response.reason_phrase
    raise MiqException::MiqVmError, msg
  end
end
