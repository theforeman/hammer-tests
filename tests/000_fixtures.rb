
RAND = rand(100).to_s

@org = {
  :name => "org"+RAND
}

@user = {
  :login => "some_user"+RAND,
  :mail => "some.user@email.com",
  :password => "passwd",
  :auth_source_id => 1
}
@user_id = nil

@os = {
  :name => "test_os"+RAND,
  :major => '6',
  :minor => '3',
  :family => 'Redhat',
  :release_name => 'cheeky'
}
@os_id = nil
@os_label = "#{@os[:name]} #{@os[:major]}.#{@os[:minor]}"

@arch = {
  :name => "arch"+RAND
}

#TODO: --os-family should have available types in help
@ptable = {
  :name => "ptable"+RAND,
  :file => "#{File.join(File.dirname(__FILE__))}/files/partition_layout.txt",
  :os_family => "Redhat"
}

#TODO: --type should have available types in help
@template = {
  :name => "tpl"+RAND,
  :file => "#{File.join(File.dirname(__FILE__))}/files/template.txt",
  :type => "provision"
}
@template_id = nil

@medium = {
  :name => "medium"+RAND,
  :path => "http://mirror.centos.org/#{RAND}/centos/$major.$minor/os/$arch",
  :os_family => "Redhat"
}
@medium_id = nil

@model = {
  :name => "model"+RAND,
  :info => "some model info",
  :hardware_model => "hw0811",
  :vendor_class => "GPUZC-M"
}
@model_id = nil

