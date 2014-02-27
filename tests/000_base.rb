
RAND = rand(100).to_s

org = {
  :name => "Org"+RAND
}

user = {
  :login => "some_user"+RAND,
  :mail => "some.user@email.com",
  :password => "passwd",
  :auth_source_id => 1
}
user_id = nil

os = {
  :name => "test_os"+RAND,
  :major => '6',
  :minor => '3'
}
os_id = nil

arch = {
  :name => "arch"+RAND
}

#TODO: --os-family should have available types in help
ptable = {
  :name => "ptable"+RAND,
  :file => "#{File.join(File.dirname(__FILE__))}/files/partition_layout.txt",
  :os_family => "Redhat"
}

#TODO: --type should have available types in help
template = {
  :name => "tpl"+RAND,
  :file => "#{File.join(File.dirname(__FILE__))}/files/template.txt",
  :type => "provision"
}

section "organization" do

  section "create" do
    simple_test "organization", "create", org
  end

end

section "user" do

  section "create" do

    res = hammer "--csv", "user", "create", user
    out = SimpleCsvOutput.new(res.stdout)

    user_id = out.column("Id")

    test "returns ok" do
      res.ok?
    end
  end

  section "assing to organization" do
    simple_test "organization", "add_user", "--name", org[:name], "--user-id", user_id
  end

end


section "architecture" do

  section "list" do
    res = hammer "architecture", "list"
    out = ListOutput.new(res.stdout)

    test "returns ok" do
      res.ok?
    end

    test_has_columns out, "Id", "Name"
  end

  section "create" do
    simple_test "architecture", "create", arch
  end

  section "info by id" do
    res = hammer "architecture", "info", arch.slice(:name)
    out = ShowOutput.new(res.stdout)

    test "returns ok" do
      res.ok?
    end

    test_has_columns out, "Id", "Name", "OS Ids"

  end
end


section "partition table" do

  section "create" do
    simple_test "partition_table", "create", ptable
  end

end


section "template" do

  section "create" do
    simple_test "template", "create", template
  end

end


section "operating system" do

  section "create" do
    res = hammer "--csv", "os", "create", os
    out = SimpleCsvOutput.new(res.stdout)

    os_id = out.column("Id")

    test "returns ok" do
      res.ok?
    end

  end

  section "add architecture" do
    simple_test "os", "add_architecture", "--id", os_id, "--architecture", arch[:name]
  end

  section "add partition table" do
    simple_test "os", "add_ptable", "--id", os_id, "--ptable", ptable[:name]
  end

  section "add template" do
    simple_test "os", "add_configtemplate", "--id", os_id, "--template", ptable[:name]
  end

end


section "deletions" do

  section "organization" do
    simple_test "organization", "delete", org.slice(:name)
  end

  section "user" do
    #TODO: delete by login
    simple_test "user", "delete", "--id", user_id
  end

  section "architecture" do
    simple_test "architecture", "delete", arch.slice(:name)
  end

  section "operating system" do
    #TODO: delete by name
    simple_test "os", "delete", "--id", os_id
  end

  section "partition table" do
    simple_test "partition_table", "delete", ptable.slice(:name)
  end

  section "template" do
    simple_test "template", "delete", template.slice(:name)
  end



end
