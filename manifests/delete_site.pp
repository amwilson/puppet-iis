define iis::delete_site($site_name = $title) {
  include 'iis::param::powershell'

  exec { "DeleteSite-${site_name}" :
    command   => "${iis::param::powershell::command} -Command \"Import-Module WebAdministration; Remove-WebSite -Name \\\"${site_name}\\\"\"",
    path      => "${iis::param::powershell::path};${::path}",
    onlyif    => "${iis::param::powershell::command} -Command \"Import-Module WebAdministration; if(!(Test-Path \\\"IIS:\\Sites\\${site_name}\\\")) { exit 1 } else { exit 0 }\"",
    logoutput => true,
  }
}