RAND = rand(100).to_s

@org = {
  :name => "org"+RAND
}

@loc = {
  :name => "loc"+RAND
}

section "organization" do

  section "create" do
    simple_test "organization", "create", @org
  end

end

section "location" do

  section "create" do
    simple_test "location", "create", @loc
  end

end


#create product
# create package repo
#  sync the repo
# create puppet repo
#  sync the repo
#create content view
# add a package
# add a puppet module
# remove a package
# remove a puppet module
#delete content view
#delete package repo
#delete package repo
#delete product

section "deletions" do

  section "organization" do
    simple_test "organization", "delete", @org.slice(:name)
  end

  section "location" do
    simple_test "location", "delete", @loc.slice(:name)
  end

end
