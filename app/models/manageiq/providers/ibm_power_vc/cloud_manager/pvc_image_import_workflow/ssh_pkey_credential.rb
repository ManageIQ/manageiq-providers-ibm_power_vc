class ManageIQ::Providers::IbmPowerVc::CloudManager::PvcImageImportWorkflow::SshPkeyCredential < Ansible::Runner::Credential
  def self.auth_type
    'ManageIQ::Providers::IbmPowerVc::CloudManager::PvcImageImportWorkflow::SshPkeyAuth'
  end

  def write_config_files
    write_password_file
    write_ssh_key_file
  end

  def write_password_file
    password_hash = initialize_password_data
    ssh_unlock_phrase = '^Enter passphrase for'.freeze
    password_hash[ssh_unlock_phrase] = auth.auth_key_password if auth.auth_key_password.present?
    File.write(password_file, password_hash.to_yaml) if password_hash.present?
  end

  def write_ssh_key_file
    File.write(ssh_key_file, "#{auth.auth_key.strip}\n\n")
  end
end
