
RAND = rand(100).to_s


@org = {
  :name => "organization"+RAND
}

@loc = {
  :name => "location"+RAND
}

@taxonomies = {
  :organizations => @org[:name],
  :locations => @loc[:name]
}

@role = {
  :name => "role"+RAND,
  :description => "Description\nof the new\nrole",
}.merge(@taxonomies)

section "workflow around filters" do

  section "prepare taxonomies" do
    simple_test "organization", "create", @org
    simple_test "location", "create", @loc
  end

  section "create new empty role" do

    simple_test "role", "create", @role.to_opts

    res = hammer "role", "info", @role.slice(:name).to_opts
    out = ShowOutput.new(res.stdout)

    test "info output" do
      out.matches?([
        ['Id:', /[0-9]+/],
        ['Name:', @role[:name]],
        ['Builtin:', 'no'],
        ['Description:', 'Description'],
        ['of the new'],
        ['role']
      ])
    end

    # test "info description formatting", :expected_failure => {
    #   :issue => '60001',
    #   :desc => 'Description in role info needs multiline formatting' } do # TODO: report issue about description formatting

    #   out.matches?([
    #     nil,
    #     nil,
    #     nil,
    #     ['Description:'],
    #     ['  Description'],
    #     ['  of the new'],
    #     ['  role']
    #   ])
    # end
  end

  # TODO: create filter with wrong permissions
  section "add a filter to the role" do
    @filter = {
      :override => "no",
      :role => @role[:name],
      :permissions => "view_users,create_users,edit_users,destroy_users"
    }

    section "prints warning when override is true and taxonomies are used" do
      # TODO: find a way of accepting hammer failures
      res = hammer "filter", "create", @filter.merge(@taxonomies).to_opts

      test "prints warning" do
        res.stderr.include?("Error: Organizations and locations can be set only for overriding filters")
      end
    end

    res = hammer "--output", "csv", "filter", "create", @filter.to_opts
    out = SimpleCsvOutput.new(res.stdout)

    @filter1_id = out.column("Id")

    res = hammer "filter", "info", "--id", @filter1_id
    out = ShowOutput.new(res.stdout)

    test "info output" do
      out.matches?([
        ['Id:', /[0-9]+/],
        ['Resource type:', 'User'],
        ['Search:', 'none'],
        ['Unlimited?:', 'yes'],
        ['Override?:', 'no'],
        ['Role:', @role[:name]],
        ['Permissions:', 'view_users, create_users, edit_users, destroy_users']
      ])
    end
  end

  section "switch a filter to overriding one" do
    @filter_update = {
      :override => "yes"
    }.merge(@taxonomies)

    simple_test "filter", "update", "--id", @filter1_id, @filter_update.to_opts

    res = hammer "filter", "info", "--id", @filter1_id
    out = ShowOutput.new(res.stdout)

    test "info output" do
      out.matches?([
        ['Id:', /[0-9]+/],
        ['Resource type:', 'User'],
        ['Search:', 'none'],
        ['Unlimited?:', 'no'],
        ['Override?:', 'yes'],
        ['Role:', @role[:name]],
        ['Permissions:', 'view_users, create_users, edit_users, destroy_users'],
        ['Locations:'],
        ["    #{@loc[:name]}"],
        ['Organizations:'],
        ["    #{@org[:name]}"]
      ])
    end
  end

  section "add an overriding filter to the role" do
    @filter = {
      :override => "yes",
      :role => @role[:name],
      :permissions => "view_users,create_users,edit_users,destroy_users"
    }.merge(@taxonomies)

    res = hammer "--output", "csv", "filter", "create", @filter.to_opts
    out = SimpleCsvOutput.new(res.stdout)

    @filter2_id = out.column("Id")

    res = hammer "filter", "info", "--id", @filter2_id
    out = ShowOutput.new(res.stdout)

    test "info output" do
      out.matches?([
        ['Id:', /[0-9]+/],
        ['Resource type:', 'User'],
        ['Search:', 'none'],
        ['Unlimited?:', 'no'],
        ['Override?:', 'yes'],
        ['Role:', @role[:name]],
        ['Permissions:', 'view_users, create_users, edit_users, destroy_users'],
        ['Locations:'],
        ["    #{@loc[:name]}"],
        ['Organizations:'],
        ["    #{@org[:name]}"]
      ])
    end
  end

  section "switch a filter to non-overriding one" do
    @filter_update = {
      :override => "false"
    }

    simple_test "filter", "update", "--id", @filter2_id, @filter_update.to_opts

    res = hammer "filter", "info", "--id", @filter2_id
    out = ShowOutput.new(res.stdout)

    test "it resets taxonomies" do
      out.matches?([
        ['Id:', /[0-9]+/],
        ['Resource type:', 'User'],
        ['Search:', 'none'],
        ['Unlimited?:', 'yes'],
        ['Override?:', 'no'],
        ['Role:', @role[:name]],
        ['Permissions:', 'view_users, create_users, edit_users, destroy_users'],
        ['Created at:']
      ])
    end
  end

  section "delete taxonomies" do
    simple_test "organization", "delete", @org.slice(:name)
    simple_test "location", "delete", @loc.slice(:name)
  end
end

