define iis::manage_site($site_path, $app_pool, $host_header = '', $site_name = $title, $port = '80', $ip_address = '*', $ssl = 'false') {
  include 'iis::param::powershell'

  validate_re($ssl, '^(false|true)$', 'ssl must be one of \'true\' or \'false\'')

  iis::createpath { "${site_name}-${site_path}":
    site_path => $site_path
  }

  $cmdSiteExists = "Test-Path \\\"IIS:\\Sites\\${site_name}\\\""

  $createSwitches = ["-Name \\\"${site_name}\\\"",
                      "-Port ${port} -IP ${ip_address}",
                      "-HostHeader \\\"${host_header}\\\"",
                      "-PhysicalPath \\\"${site_path}\\\"",
                      "-ApplicationPool \\\"${app_pool}\\\"",
                      "-Ssl:$${ssl}"]

  $switches = join($createSwitches,' ')

  exec { "CreateSite-${site_name}" :
    command   => "${iis::param::powershell::command} -Command \"Import-Module WebAdministration; New-WebSite ${switches} \"",
    path      => "${iis::param::powershell::path};${::path}",
    onlyif    => "${iis::param::powershell::command} -Command \"Import-Module WebAdministration; if(${$cmdSiteExists}) { exit 1 } else { exit 0 }\"",
    logoutput => true,
    require   => [ Iis::Createpath["${site_name}-${site_path}"], Iis::Manage_app_pool[$app_pool] ],
  }

  exec { "UpdateSite-PhysicalPath-${site_name}":
    command   => "${iis::param::powershell::command} -Command \"Import-Module WebAdministration; Set-ItemProperty \\\"IIS:\\Sites\\${site_name}\\\" -Name physicalPath -Value \\\"${site_path}\\\"\"",
    onlyif    => "${iis::param::powershell::command} -Command \"Import-Module WebAdministration; if((${$cmdSiteExists}) -eq \$true -and (!(Get-ItemProperty \\\"IIS:\\Sites\\${site_name}\\\" physicalPath) -eq \\\"${site_path}\\\")) { exit 1 } else { exit 0 }\"",
    path      => "${iis::param::powershell::path};${::path}",
    logoutput => true,
    require   => Exec["CreateSite-${site_name}"],
  }

  exec { "UpdateSite-ApplicationPool-${site_name}":
    command   => "${iis::param::powershell::command} -Command \"Import-Module WebAdministration; Set-ItemProperty \\\"IIS:\\Sites\\${site_name}\\\" -Name applicationPool -Value \\\"${app_pool}\\\"\"",
    onlyif    => "${iis::param::powershell::command} -Command \"Import-Module WebAdministration; if((${$cmdSiteExists}) -eq \$true -and (!(Get-ItemProperty \\\"IIS:\\Sites\\${site_name}\\\" applicationPool) -eq \\\"${app_pool}\\\")) { exit 1 } else { exit 0 }\"",
    path      => "${iis::param::powershell::path};${::path}",
    logoutput => true,
    require   => Exec["CreateSite-${site_name}"],
  }
}
