# Kernelcare Cookbook

The Kernelcare Cookbook provides resources for installing kernelcare.

## Dependencies

### Platform Support

- Amazon Linux
- Debian 8/9
- Ubuntu 14.04/16.04/18.04
- CentOS 6/7/8

## Usage

- Add `depends 'kernelcare'` to your cookbook's metadata.rb
- Use the `kernelcare` resources shipped in cookbook in a recipe, the same way you'd use core Chef resources (file, template, directory, package, etc).

```ruby
kernelcare 'install_kernelcare'

kernelcare 'install_register_kernelcare_and_update' do
    registration_key 'test'
    update true
end

kernelcare 'install_kernelcare_and_config' do
    auto_update false
    patch_server 'http://10.1.10.115/'
    registration_url 'http://10.1.10.115/admin/api/kcare'
    prefix 'test'
    sticky_patch '250518'
end
```
