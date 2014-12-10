

section "smart proxy" do


  section "find or create create" do
    res = hammer "--csv", "proxy", "list", "--search", "url=#{@proxy[:url]}"
    out = CsvOutput.new(res.stdout)

    if out.column("Id").length > 0
      @proxy[:name] = out.column("Name")[0]
      @proxy_id = out.column("Id")[0]
      @proxy_created = false
    else
      res = hammer "--csv", "proxy", "create", @proxy
      out = SimpleCsvOutput.new(res.stdout)
      @proxy_id = out.column("Id")
      @proxy_created = true

      test_result res
    end

  end


  section "info" do
    res = hammer "proxy", "info", @proxy.slice(:name)
    out = ShowOutput.new(res.stdout)

    test_result res

    test_has_columns out, "Id", "Name", "URL", "Features"

    test_column_value out, "Id", @proxy_id
    test_column_value out, "Name", @proxy[:name]
    test_column_value out, "URL", @proxy[:url]
    # features are not checked by intention as they may differ accross testing envs
  end

  section "import classes" do
    simple_test "proxy", "import-classes", @proxy.slice(:name)
  end

  section "deletion" do
    simple_test "proxy", "delete", @proxy.slice(:name) if @proxy_created
  end

end
