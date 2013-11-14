define iis::manage_site($site_path, $app_pool, $host_header = '', $site_name = $title, $port = '80', $ip_address = '*', $ssl = 'false') {
  include 'iis::param::powershell'

  validate_re($ssl, '^(false|true)$', 'ssl must be one of \'true\' or \'false\'')

  iis::createpath { "${site_name}-${site_path}":
    site_path => $site_path
  }

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
    onlyif    => "${iis::param::powershell::command} -Command \"Import-Module WebAdministration; if((Test-Path \\\"IIS:\\Sites\\${site_name}\\\")) { exit 1 } else { exit 0 }\"",
    logoutput => true,
    require   => [ Iis::Createpath["${site_name}-${site_path}"], Iis::Manage_app_pool[$app_pool] ],
  }

  exec { "Set-PhysicalPath-${site_name}":
    path      => "${iis::param::powershell::path};${::path}",
    logoutput => true,
    require   => Exec["CreateSite-${site_name}"],
  }
}
