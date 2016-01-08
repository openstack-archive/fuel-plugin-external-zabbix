# check_zabbix_pacemaker.rb

Facter.add('check_zabbix_pacemaker') do
  setcode do
    crm_cmd = Facter::Util::Resolution.exec('/bin/which crm')
    if crm_cmd.nil? then
      ''
    else
      crm_res = Facter::Util::Resolution.exec(crm_cmd + ' status | grep zabbix' )
    end
  end
end
