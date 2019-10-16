resource_name :kernelcare
provides :kernelcare

property :auto_update, [true, false], default: true
property :registration_key, String
property :patch_server, String
property :registration_url, String
property :prefix, String
property :sticky_patch, String
property :update, [true, false], default: true

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

  if property_is_set?(:registration_key)
    execute "kcarectl --register #{new_resource.registration_key}" do
      creates '/etc/sysconfig/kcare/systemid'
    end
  end

  if property_is_set?(:auto_update)
    execute "sed -i -n -e '/^AUTO_UPDATE=/!p' -e '$aAUTO_UPDATE=#{new_resource.auto_update}' #{new_resource.config_location}"
  end

  if property_is_set?(:patch_server)
    execute "sed -i -n -e '/^PATCH_SERVER=/!p' -e '$aPATCH_SERVER=#{new_resource.patch_server}' #{new_resource.config_location}"
  end

  execute 'kcarectl --update' do
    only_if { new_resource.update }
  end
end
