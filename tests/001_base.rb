
def test_os_association(resource, params)

  section "add/remove os" do
    simple_test resource, "add-operatingsystem", "--operatingsystem", @os_label, params

    section "os associated" do
      res = hammer resource, "info", params
      out = ShowOutput.new(res.stdout)

      test_result res

      test_column_value out, "Operating systems", @os_label
    end

    simple_test resource, "remove-operatingsystem", "--operatingsystem", @os_label, params
  end

end


def test_org_association(resource, params)
  section "assign to organization" do
    simple_test "organization", "add-#{resource}", "--name", @org[:name], params
    simple_test "organization", "remove-#{resource}", "--name", @org[:name], params
  end
end



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

  test_org_association("user", :user => @user[:login])

  section "info" do
    res = hammer "user", "info", @user.slice(:login)
    out = ShowOutput.new(res.stdout)

    test_result res

    test_has_columns out, "Id", "Login", "Name", "Email"
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

end


section "operating system" do

  section "create" do
    res = hammer "--csv", "os", "create", @os
    out = SimpleCsvOutput.new(res.stdout)

    @os_id = out.column("Id")

    test_result res

  end

end


section "partition table" do

  section "create" do
    simple_test "partition-table", "create", @ptable
  end

  section "dump" do
    res = hammer "partition-table", "dump", @ptable.slice(:name)

    test_result res

    test "dumps the content" do
      res.stdout.strip == "PARTITION LAYOUT"
    end
  end

  test_os_association("partition-table", :name => @ptable[:name])

end


section "installation medium" do

  section "create" do
    res = hammer "--csv", "medium", "create", @medium
    out = SimpleCsvOutput.new(res.stdout)

    @medium_id = out.column("Id")

    test_result res
  end

  test_org_association("medium", :medium => @medium[:name])
  test_os_association("medium", :name => @medium[:name])

end


section "template" do

  section "create" do
    res = hammer "--csv", "template", "create", @template
    out = SimpleCsvOutput.new(res.stdout)

    @template_id = out.column("Id")

    test_result res
  end

  section "dump" do
    res = hammer "template", "dump", @template.slice(:name)

    test_result res

    test "dumps the content" do
      res.stdout.strip == "TEMPLATE"
    end
  end

  test_org_association("config-template", 'config-template' => @template[:name])
  test_os_association("template", :name => @template[:name])

  section "kinds" do
    simple_test "template", "kinds"
  end

end


section "hardware model" do

  section "create" do
    simple_test "model", "create", @model
  end

  section "info" do
    res = hammer "model", "info", @model.slice(:name)
    out = ShowOutput.new(res.stdout)

    test_result res

    test_has_columns out, "Id", "Name", "Vendor class", "HW model", "Info"
    test_column_value out, "Name", @model[:name]
    test_column_value out, "HW model", @model[:hardware_model]
    test_column_value out, "Vendor class", @model[:vendor_class]
  end

end



section "operating system" do

  section "add architecture" do
    simple_test "os", "add-architecture", "--id", @os_id, "--architecture", @arch[:name]
  end

  section "add partition table" do
    simple_test "os", "add-ptable", "--id", @os_id, "--partition-table", @ptable[:name]
  end

  section "add template" do
    simple_test "os", "add-config-template", "--id", @os_id, "--config-template", @template[:name]
  end

  #TODO: add-medium is missing
  section "add medium" do
    simple_test "os", "update", "--id", @os_id, "--medium-ids", @medium_id
  end

  section "info by id" do
    res = hammer "os", "info", "--id", @os_id
    out = ShowOutput.new(res.stdout)

    test_result res

    test_has_columns out, "Id", "Name", "Release name", "Family"
    test_has_columns out, "Installation media", "Architectures", "Partition tables", "Templates", "Parameters"

    test_column_value out, "Id", @os_id
    test_column_value out, "Title", @os_label
    test_column_value out, "Name", @os[:name]
    test_column_value out, "Release name", @os[:release_name]
    test_column_value out, "Family", @os[:family]
    test_column_value out, "Installation media", @medium[:name]
    test_column_value out, "Architectures", @arch[:name]
    test_column_value out, "Partition tables", @ptable[:name]
    test_column_value out, "Templates", @template[:name] + " (provision)"

  end

end


section "architecture" do

  section "info" do
    res = hammer "architecture", "info", @arch.slice(:name)
    out = ShowOutput.new(res.stdout)

    test_result res

    test_has_columns out, "Id", "Name", "Operating systems"
    test_column_value out, "Name", @arch[:name]
    test_column_value out, "Operating systems", @os_label
  end

end

section "installation medium" do

  section "info" do
    res = hammer "medium", "info", @medium.slice(:name)
    out = ShowOutput.new(res.stdout)

    test_result res

    test_has_columns out, "Id", "Path", "OS Family", "Operating systems"
    test_column_value out, "Name", @medium[:name]
    test_column_value out, "OS Family", @medium[:os_family]
    test_column_value out, "Operating systems", @os_label
    test_column_value out, "Path", @medium[:path]
  end

end

section "partition table" do

  section "info" do
    res = hammer "partition-table", "info", @ptable.slice(:name)
    out = ShowOutput.new(res.stdout)

    test_result res

    test_has_columns out, "Id", "Name", "OS Family"
    test_column_value out, "Name", @ptable[:name]
    test_column_value out, "OS Family", @ptable[:os_family]
    test_column_value out, "Operating systems", @os_label
  end

end

section "template" do
  section "info" do
    res = hammer "template", "info", @template.slice(:name)
    out = ShowOutput.new(res.stdout)

    test_result res

    test_has_columns out, "Id", "Name", "Type", "Operating systems"
    test_column_value out, "Name", @template[:name]
    test_column_value out, "Type", @template[:type]
    test_column_value out, "Operating systems", @os_label
  end

end
