require 'spec_helper'

powershell = 'powershell.exe -ExecutionPolicy RemoteSigned'

describe 'iis::delete_site', :type => :define do
  describe 'when deleting the iis site' do
    let(:title) { 'myWebSite' }

    it { should contain_exec('DeleteSite-myWebSite').with({
      'command' => "#{powershell} -Command \"Import-Module WebAdministration; Remove-WebSite -Name \\\"myWebSite\\\"\"",
      'onlyif'  => "#{powershell} -Command \"Import-Module WebAdministration; if(!(Test-Path \\\"IIS:\\Sites\\myWebSite\\\")) { exit 1 } else { exit 0 }\"",
    })}
  end
end
