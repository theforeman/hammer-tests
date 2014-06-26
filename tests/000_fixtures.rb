
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

@proxy = {
  :name => "proxy"+RAND,
  :url => "http://localhost:8443"
}
@proxy_id = nil

@domain = {
  :name => "domain"+RAND,
  :description => "domain description"
}

@param_a = {
  :name => "param_a",
  :value => "A",
}

@param_b = {
  :name => "param_b",
  :value => "B",
}

@role = {
  :name => "role"+RAND
}
@new_role_name = @role[:name]+'_2'

@filter = {
  :role => @new_role_name,
  :permission_ids => '1,2,3',
  :search => 'architecture.id=1'
}

@updated_filter = {
  :permission_ids => '3,4',
  :search => 'architecture.id=2'
}
