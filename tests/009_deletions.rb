
section "deletions" do

  section "organization" do
    simple_test "organization", "delete", @org.slice(:name)
  end

  section "user" do
    #TODO: delete by login
    simple_test "user", "delete", "--id", @user_id
  end

  section "architecture" do
    simple_test "architecture", "delete", @arch.slice(:name)
  end

  section "operating system" do
    #TODO: delete by name
    simple_test "os", "delete", "--id", @os_id
  end

  section "partition table" do
    simple_test "partition-table", "delete", @ptable.slice(:name)
  end

  section "hardware model" do
    simple_test "model", "delete", @model.slice(:name)
    # simple_test "model", "delete", "--id", @template_id
  end

  section "template" do
    simple_test "template", "delete", @template.slice(:name)
  end

end
