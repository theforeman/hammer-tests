

section "organization" do

  section "create" do
    simple_test "organization", "create", @org
  end

end

section "user" do

  section "create" do

    res = hammer "--csv", "user", "create", @user
    out = SimpleCsvOutput.new(res.stdout)

    @user_id = out.column("Id")

    test_result res
  end

  section "assing to organization" do
    simple_test "organization", "add_user", "--name", @org[:name], "--user-id", @user_id
  end

end


section "architecture" do

  section "list" do
    res = hammer "architecture", "list"
    out = ListOutput.new(res.stdout)

    test_result res

    test_has_columns out, "Id", "Name"
  end

  section "create" do
    simple_test "architecture", "create", @arch
  end

  section "info by id" do
    res = hammer "architecture", "info", @arch.slice(:name)
    out = ShowOutput.new(res.stdout)

    test_result res

    test_has_columns out, "Id", "Name", "OS ids"

  end
end


section "partition table" do

  section "create" do
    simple_test "partition_table", "create", @ptable
  end

end


section "installation medium" do

  section "create" do
    res = hammer "--csv", "medium", "create", @medium
    out = SimpleCsvOutput.new(res.stdout)

    medium_id = out.column("Id")

    test_result res
  end

end


section "template" do

  section "create" do
    res = hammer "--csv", "template", "create", @template
    out = SimpleCsvOutput.new(res.stdout)

    template_id = out.column("Id")

    test_result res
  end

end


section "hardware model" do

  section "create" do
    simple_test "model", "create", @model
  end

end



section "operating system" do

  section "create" do
    res = hammer "--csv", "os", "create", @os
    out = SimpleCsvOutput.new(res.stdout)

    @os_id = out.column("Id")

    test_result res

  end

  section "add architecture" do
    simple_test "os", "add_architecture", "--id", @os_id, "--architecture", @arch[:name]
  end

  section "add partition table" do
    simple_test "os", "add_ptable", "--id", @os_id, "--ptable", @ptable[:name]
  end

  section "add template" do
    simple_test "os", "add_configtemplate", "--id", @os_id, "--configtemplate", @template[:name]
  end

  #TODO: add_medium is missing
  section "add medium" do
    simple_test "os", "update", "--id", @os_id, "--medium-ids", @medium_id
  end

  section "info by id" do
    res = hammer "os", "info", "--id", @os_id
    out = ShowOutput.new(res.stdout)

    test_result res

    test_has_columns out, "Id", "Name", "Release name", "Family"
    test_has_columns out, "Installation media", "Architectures", "Partition tables", "Config templates", "Parameters"

    test_column_value out, "Id", @os_id
    test_column_value out, "Name", @os_label
    test_column_value out, "Release name", @os[:release_name]
    test_column_value out, "Family", @os[:family]
    test_column_value out, "Installation media", @medium[:name]
    test_column_value out, "Architectures", @arch[:name]
    test_column_value out, "Partition tables", @ptable[:name]
    test_column_value out, "Config templates", @template[:name]

  end

end
