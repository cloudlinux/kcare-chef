resource_name :kernelcare
provides :kernelcare

property :auto_update, [true, false], default: true
property :registration_key, String
property :patch_server, String
property :registration_url, String
property :prefix, String
property :sticky_patch, String
property :update, [true, false], default: true
property :lib_auto_update, [true, false], default: false
property :lib_update, [true, false], default: false
property :scanner_interface, String

property :install_script_url, String, default: 'https://kernelcare.com/installer'
property :config_location, String, default: '/etc/sysconfig/kcare/kcare.conf'

action :install do
  remote_file 'download_install_script' do
    source new_resource.install_script_url
    path "#{Chef::Config[:file_cache_path]}/kernelcare_install.sh"
    action :create
  end

  execute 'install_kernelcare' do
    command "bash #{Chef::Config[:file_cache_path]}/kernelcare_install.sh"
    creates '/etc/sysconfig/kcare/kcare.conf'
  end

  if property_is_set?(:auto_update)
    execute "sed -i -n -e '/^AUTO_UPDATE=/!p' -e '$aAUTO_UPDATE=#{new_resource.auto_update}' #{new_resource.config_location}"
  end

  if property_is_set?(:patch_server)
    execute "sed -i -n -e '/^PATCH_SERVER=/!p' -e '$aPATCH_SERVER=#{new_resource.patch_server}' #{new_resource.config_location}"
  end

  if property_is_set?(:registration_url)
    execute "sed -i -n -e '/^REGISTRATION_URL=/!p' -e '$aREGISTRATION_URL=#{new_resource.registration_url}' #{new_resource.config_location}"
  end

  if property_is_set?(:registration_key)
    execute "kcarectl --register #{new_resource.registration_key}" do
      creates '/etc/sysconfig/kcare/systemid'
    end
  end

  if new_resource.lib_auto_update
  then
    execute '/usr/bin/libcare-cron init' do
      creates '/etc/cron.d/libcare-cron'
    end
  else
    execute '/usr/bin/libcare-cron disable' do
      only_if { ::File.exists? '/etc/cron.d/libcare-cron' }
    end
  end

  if property_is_set?(:scanner_interface)
    execute "/usr/bin/kcare-scanner-interface init #{new_resource.scanner_interface}"
  else
    execute '/usr/bin/kcare-scanner-interface disable'
  end

  execute 'kcarectl --update' do
    only_if { new_resource.update }
  end

  execute 'kcarectl --lib-update' do
    only_if { new_resource.lib_update }
  end
end
