
RAND = rand(100).to_s

@ldap = {
  :name => "FreeIPA ldap "+RAND,
  :host => "ipa.test.org",
  :server_type => "free_ipa",
  :tls => "no",
  :account => "uid=admin,cn=users,cn=accounts,dc=ipa,dc=test",
  :base_dn => "cn=users,cn=accounts,dc=ipa,dc=test",
  :groups_base => "cn=ng,cn=compat,dc=ipa,dc=test",
  :onthefly_register => "yes",
  :usergroup_sync => "no",
  :use_netgroups => "yes",
  :attr_login => "uid",
  :attr_firstname => "givenName",
  :attr_lastname => "sn",
  :attr_mail => "main",
  :attr_photo => "photo"
}

section "ldap auth source" do
  section "create and test details" do
    res = hammer "--csv", "auth-source", "ldap", "create", @ldap
    test_result res
    out = SimpleCsvOutput.new(res.stdout)

    @ldap_id = out.column("Id")

    res = hammer "auth-source", "ldap", "list"
    out = ListOutput.new(res.stdout)

    test "the auth shource is listed" do
      out.contains_line?([/[0-9]+/, @ldap[:name], @ldap[:host], '389', 'no'])
    end

    res = hammer "auth-source", "ldap", "info", "--name", @ldap[:name]
    test_result res

    out = ShowOutput.new(res.stdout)

    DATE_REGEXP = /[0-9]{4}\/[0-9]{2}\/[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}/

    test "info output" do
      out.matches?([
        ['Server:'],
        ['    Id:', /[0-9]+/],
        ['    Name:', @ldap[:name]],
        ['    Server:', @ldap[:host]],
        ['    LDAPS:', @ldap[:tls]],
        ['    Port:', '389'],
        ['    Server Type:', @ldap[:server_type]],
        ['Account:'],
        ['    Account Username:', @ldap[:account]],
        ['    Base DN:', @ldap[:base_dn]],
        ['    Groups base DN:', @ldap[:groups_base]],
        ['    Use Netgroups:', @ldap[:use_netgroups]],
        ['    LDAP filter:'],
        ['    Automatically Create Accounts?:', @ldap[:onthefly_register]],
        ['    Usergroup sync:',                 @ldap[:usergroup_sync]],
        ['Attribute mappings:'],
        ['    Login Name Attribute:',    @ldap[:attr_login]],
        ['    First Name Attribute:',    @ldap[:attr_firstname]],
        ['    Last Name Attribute:',     @ldap[:attr_lastname]],
        ['    Email Address Attribute:', @ldap[:attr_mail]],
        ['    Photo Attribute:',         @ldap[:attr_photo]]
      ])
    end
  end

  section "delete the auth source" do
    res = hammer "auth-source", "ldap", "delete", "--name", @ldap[:name]
    test_result res

    test "output message" do
      res.stdout == "Auth source [#{@ldap[:name]}] deleted\n"
    end

    res = hammer "user", "list"
    out = ListOutput.new(res.stdout)

    test "the auth source isn't listed any more" do
      !out.contains_line?([/[0-9]+/, @ldap[:name]])
    end
  end
end
