require 'spec_helper'

powershell = 'powershell.exe -ExecutionPolicy RemoteSigned'

describe 'iis::delete_app_pool', :type => :define do
  describe 'when deleting the iis application pool' do
    let(:title) { 'myAppPool.example.com' }

    it { should contain_exec('Delete-myAppPool.example.com').with( {
       :command => "#{powershell} -Command \"Import-Module WebAdministration; Remove-Item \\\"IIS:\\AppPools\\myAppPool.example.com\\\" -Recurse\"",
       :onlyif  => "#{powershell} -Command \"Import-Module WebAdministration; if(!(Test-Path \\\"IIS:\\AppPools\\myAppPool.example.com\\\")) { exit 1 } else { exit 0 }\"",
    }) }

    it { should_not contain_exec('Framework-myAppPool.example.com') }

    it { should_not contain_exec('32bit-myAppPool.example.com') }
  end
end