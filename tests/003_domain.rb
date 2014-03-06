

section "domain" do

  section "create" do
    res = hammer "domain", "create", @domain
    test_result res
  end

  section "parameters" do
    res = hammer "domain", "set_parameter", "--domain-name", @domain[:name], @param_a
    test_result res
    res = hammer "domain", "set_parameter", "--domain-name", @domain[:name], @param_b
    test_result res
    res = hammer "domain", "delete_parameter", "--domain-name", @domain[:name], @param_b.slice(:name)
    test_result res
  end

  section "info" do
    res = hammer "domain", "info", @domain.slice(:name)
    out = ShowOutput.new(res.stdout)

    test_result res

    test_has_columns out, "Id", "Name", "Description", "DNS Id", "Parameters"

    test_column_value out, "Name", @domain[:name]
    test_column_value out, "Description", @domain[:description]
  end


  section "deletion" do
    simple_test "domain", "delete", @domain.slice(:name)
  end

end
