define iis::delete_app_pool($app_pool_name = $title) {
  include 'param::powershell'

  exec { "Delete-${app_pool_name}" :
    command   => "${iis::param::powershell::command} -Command \"Import-Module WebAdministration; Remove-Item \\\"IIS:\\AppPools\\${app_pool_name}\\\" -Recurse\"",
    path      => "${iis::param::powershell::path};${::path}",
    onlyif    => "${iis::param::powershell::command} -Command \"Import-Module WebAdministration; if(!(Test-Path \\\"IIS:\\AppPools\\${app_pool_name}\\\")) { exit 1 } else { exit 0 }\"",
    logoutput => true,
  }
}