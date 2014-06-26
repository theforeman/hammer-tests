
require File.join(File.dirname(__FILE__), '000_fixtures.rb')


section "role" do

  section "create" do
    simple_test "role", "create", @role
  end

  section "list" do
    res = hammer "role", "list"
    test "contains created role" do
      res.stdout.include? @role[:name]
    end
  end

  section "filters" do
    simple_test "role", "filters", @role.slice(:name)
  end

  section "update" do
    simple_test "role", "update", "--new-name", @new_role_name, @role.slice(:name)
  end

end

section "filter" do

  section "available permissions and resources" do

    test "permissions" do
      simple_test "filter", "available-permissions"
    end

    test "resources" do
      simple_test "filter", "available-resources"
    end

  end

  section "create" do
    res = hammer "--csv", "filter", "create", @filter
    out = SimpleCsvOutput.new(res.stdout)

    @filter_id = out.column("Id")
  end

  section "info" do
    simple_test "filter", "info", "--id", @filter_id
  end

  section "list" do
    simple_test "filter", "list"
  end

  section "update" do
    simple_test "filter", "update", "--id", @filter_id, @updated_filter
  end

end

section "deletions" do

  section "filter" do
    simple_test "filter", "delete", "--id", @filter_id
  end

  section "role" do
    simple_test "role", "delete", "--name", @new_role_name
  end

end
