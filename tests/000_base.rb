
RAND = rand(100).to_s
org_name = "Org"+RAND
os_name = "test_os"+RAND
user = {
  :login => "some_user"+RAND,
  :mail => "some.user@email.com"
}

section "organization" do

  section "create" do
    res = hammer "organization", "create", "--name", org_name
    out = ListOutput.new(res.stdout)

    test "returns ok" do
      res.ok?
    end
  end

end

section "user" do

  section "create" do
    simple_test "user", "create", "--login", user[:login], "--mail", user[:mail], "--password", "passwd", "--auth-source-id=1"
  end

  section "assing to organization" do
    simple_test "organization", "add_user", "--name", org_name, "--user-id", "10"
  end

end


section "operating system" do

  section "create" do
    simple_test "os", "create", "--name", os_name, "--major", '6', "--minor", "3"
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

  section "info by id" do
    res = hammer "architecture", "info", "--id=1"
    out = ShowOutput.new(res.stdout)

    test "returns ok" do
      res.ok?
    end

    test_has_columns out, "Id", "Name", "OS Ids"

  end
end

section "deletions" do

  section "organization" do
    simple_test "organization", "delete", "--name", org_name
  end

  section "user" do
    simple_test "user", "delete", "--login", user[:login]
  end

end
