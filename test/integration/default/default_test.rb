# InSpec test for recipe kernelcare::default

# The InSpec reference, with examples and extensive documentation, can be
# found at https://www.inspec.io/docs/reference/resources/

describe file('/etc/sysconfig/kcare/kcare.conf') do
  its('content') { should match(/AUTO_UPDATE=True/) }
end
