
RAND = rand(100).to_s

@user = {
  :login => "some_user"+RAND,
  :mail => "some.user@email.com",
  :password => "passwd",
  :auth_source_id => 1 # Issue - create auth source by name
}

section "workflow around users" do

  section "create user without permissions" do

    res = hammer "--csv", "user", "create", @user
    test_result res
    out = SimpleCsvOutput.new(res.stdout)

    @user_id = out.column("Id")


    res = hammer "user", "list"
    out = ListOutput.new(res.stdout)

    test "the user is listed" do
      out.contains_line?([/[0-9]+/, @user[:login], '', @user[:email], 'no', nil,'Internal'])
    end

    res = hammer "user", "info", "--login", @user[:login]
    test_result res

    out = ShowOutput.new(res.stdout)

    DATE_REGEXP = /[0-9]{4}\/[0-9]{2}\/[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}/

    test "info output" do
      out.matches?([
        ['Id:', /[0-9]+/],
        ['Login:', @user[:login]],
        ['Name:', ''],
        ['Email:', @user[:email]],
        ['Admin:', 'no'],
        ['Last login:'],
        ['Authorized by:', 'Internal'],
        ['Effective admin:', 'no'],
        ['Locale:', 'default'],
        ['Timezone:', 'default'],
        ['Description:', ''],
        ['Default organization:', ''],
        ['Default location:', ''],
        ['Roles:'],
        ['    Default role'],
        ['User groups:'],
        [''],
        ['Inherited User groups:'],
        [''],
        ['Created at:', DATE_REGEXP],
        ['Updated at:', DATE_REGEXP]
      ])
    end


    section "change user's password to new_passwd" do
      simple_test "user", "update", "--login", @user[:login], '--ask-password', 'true' do |stdin, *_|
        stdin.puts "new_passwd"
        stdin.close
      end
    end

    # TODO: expected failure
    section "change your own password" do
      simple_test "-u", @user[:login], '-p', 'new_passwd', "user", "update", "--login", @user[:login], '--ask-password', 'true' do |stdin, *_|
        # Enter user's new password:
        stdin.puts "new_passwd2"
        # Enter user's current password:
        stdin.puts "new_passwd"
        stdin.close
      end
    end

    section "change your own password with view_permissions" do
      simple_test 'user', 'add-role', '--login', @user[:login], '--role', 'Viewer'
      simple_test "-u", @user[:login], '-p', 'new_passwd', "user", "update", "--login", @user[:login], '--ask-password', 'true' do |stdin, *_|
        # Enter user's new password:
        stdin.puts "new_passwd2"
        # Enter user's current password:
        stdin.puts "new_passwd"
        stdin.close
      end
    end
  end

  section "delete the user" do
    res = hammer "user", "delete", "--login", @user[:login]
    test_result res

    test "output message" do
      res.stdout == "User [#{@user[:login]}] deleted\n"
    end

    res = hammer "user", "list"
    out = ListOutput.new(res.stdout)

    test "the user isn't listed any more" do
      !out.contains_line?([/[0-9]+/, @user[:login]])
    end
  end
end


# create user without permissions
# check the user was created
# see user details

# uses default organization and location to create the user

# add role to the user
# test the role was added
