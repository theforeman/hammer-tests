

# section "smart proxy" do

#   section "create" do
#     res = hammer "--csv", "proxy", "create", @proxy
#     out = SimpleCsvOutput.new(res.stdout)

#     @proxy_id = out.column("Id")

#     test_result res
#   end


#   section "info" do
#     res = hammer "proxy", "info", @proxy.slice(:name)
#     out = ShowOutput.new(res.stdout)

#     test_result res

#     test_has_columns out, "Id", "Name", "URL", "Features"

#     test_column_value out, "Id", @proxy_id
#     test_column_value out, "Name", @proxy[:name]
#     test_column_value out, "URL", @proxy[:url]
#     # features are not checked by intention as they may differ accross testing envs
#   end

#   #FIX: import by name
#   section "import classes" do
#     # simple_test "proxy", "import-classes", @proxy.slice(:name)
#     simple_test "proxy", "import-classes", "--id", @proxy_id
#   end

#   section "deletion" do
#     simple_test "proxy", "delete", @proxy.slice(:name)
#   end

# end
