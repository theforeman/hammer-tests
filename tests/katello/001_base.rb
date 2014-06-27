KT_RAND = rand(100).to_s

@org = {
  :name => "org"+KT_RAND,
  :label => "lbl_org"+KT_RAND
}

@loc = {
  :name => "loc"+KT_RAND
}

@product = {
  :name => "prod"+KT_RAND,
  :label => "lbl_prod"+KT_RAND,
  :organization => @org[:name],
  :description => "some product"
}

@yum_repo = {
  :name => "yum repo"+KT_RAND,
  :label => "lbl_yum_repo"+KT_RAND,
  :organization => @org[:name],
  :product => @product[:name],
  :url => 'http://inecas.fedorapeople.org/fakerepos/new_cds/content/zoo/1.0/x86_64/rpms/',
  :content_type => 'yum'
}

@puppet_repo = {
  :name => "puppet repo"+KT_RAND,
  :label => "lbl_puppet_repo"+KT_RAND,
  :organization => @org[:name],
  :product => @product[:name],
  :content_type => 'puppet'
}

@content_path = File.join(File.dirname(__FILE__), 'content/')

@content_view = {
  :name => "cont view"+KT_RAND,
  :label => "lbl_cv"+KT_RAND,
  :organization => @org[:name],
  :description => 'some content view'
}

section "organization" do

  section "create" do
    simple_test "organization", "create", @org
  end

  section "info" do
    section "info by name" do
      simple_test "organization", "info", @org.slice(:name)
    end

    section "info by label" do
      simple_test "organization", "info", @org.slice(:label)
    end
  end

  section "list" do
    simple_test "organization", "list"
  end


end

section "location" do

  section "create" do
    simple_test "location", "create", @loc
  end

  section "list" do
    simple_test "location", "list"
  end
end

section "product" do

  section "create" do
    simple_test "product", "create", @product
  end

  section "list" do
    simple_test "product", "list", "--organization", @org[:name]
  end

  section "info" do
    simple_test "product", "info", @product.slice(:name, :organization)
  end

end

section "repo" do

  section "create yum" do
    simple_test "repository", "create", @yum_repo
  end

  section "create puppet" do
    simple_test "repository", "create", @puppet_repo
  end

  section "list" do
    simple_test "repository", "list", "--product", @product[:name], "--organization", @product[:organization]
  end

  section "upload" do
    simple_test "repository", "upload-content", "--path", @content_path, @puppet_repo.slice(:name, :product, :organization)
  end

  section "sync" do
    #temporarily disabled for it's taking too long
    #simple_test "repository", "synchronize", @yum_repo.slice(:name, :product, :organization)
  end

end

#create content view
# add a package
# add a puppet module
# remove a package
# remove a puppet module
#delete content view

section "deletions" do

  section "repo" do
    simple_test "repository", "delete", @yum_repo.slice(:name, :organization, :product)
    simple_test "repository", "delete", @puppet_repo.slice(:name, :organization, :product)
  end

  section "product" do
    simple_test "product", "delete", @product.slice(:name, :organization)
  end

  #deleting orgs is not supported
  #section "organization" do
  #  simple_test "organization", "delete", @org.slice(:name)
  #end

  section "location" do
    simple_test "location", "delete", @loc.slice(:name)
  end

end
