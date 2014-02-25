
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

os = {
  :name => "test_os"+RAND,
  :major => '6',
  :minor => '3'
}

arch = {
  :name => "arch"+RAND
}

section "organization" do

  section "create" do
    simple_test "organization", "create", org
  end

end

section "user" do

  section "create" do
    simple_test "user", "create", user
  end

  section "assing to organization" do
    simple_test "organization", "add_user", "--name", org[:name], "--user-id", "10"
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


section "operating system" do

  section "create" do
    simple_test "os", "create", os
  end

  section "add architecture" do
    simple_test "os", "add_architecture", "--id=1", "--architecture", arch[:name]
  end

end


section "deletions" do

  section "organization" do
    simple_test "organization", "delete", org.slice(:name)
  end

  section "user" do
    simple_test "user", "delete", user.slice(:login)
  end

  section "architecture" do
    simple_test "architecture", "delete", arch.slice(:name)
  end

end
