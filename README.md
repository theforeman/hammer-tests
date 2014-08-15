Hammer Tests
============

Simple tool for testing integration of Hammer CLI with Foreman.

It runs defined tests and crops relevant chunks from Foreman's and Hammer's log files.  
__BEWARE:__ It does modifications on the machine your Hammer is configured against!

Usage
-----
```
./run_tests <LIST_OF_PATHS>
```
The script accepts list of test files or directories with test files as arguments.

E.g. to run all available tests from this repo:
```
./run_tests ./tests/
```


Env Variable Settings
---------------------

- `HT_HAMMER_CMD` - path to the hammer command (default is `hammer`)
- `HT_TIMESTAMPED_LOGS` - use timestamps in names of the output log files, set to 1 to enable the functionality (disabled by default)
- `HT_LOGS_LOCATION` - target location for the output logs (default is `./log/`)
- `HT_FOREMAN_LOG_FILE` - path to the Foreman's log (default is `/var/log/foreman/development.log`)
- `HT_HAMMER_LOG_FILE` - path to the Hammer's log (default is `~/.foreman/log/hammer.log`)

Writing Tests
-------------

```ruby
section "template" do

  section "dump" do
    res = hammer "template", "dump", "--name", "tpl"
    res = hammer "template", "dump", :name => "tpl"  # equivalent of the line above

    test "returns ok" do
      # result contains return code
      res.ok?
    end

    test "dumps the content" do
      # ...and output produced to stdout and stderr
      res.stdout.strip == "TEMPLATE"
    end
  end

  section "description of the section" do
    test "whatever you want" do
      # your test goes here
      # return value of the block is used as a result of the test
      true
    end
  end

end
```

The test above will produce:

```
template
   dump
      hammer template dump --name tpl    [command #1]
      Error: config_template not found
      hammer template dump --name tpl    [command #2]
      Error: config_template not found
      [FAIL] returns ok
      [FAIL] dumps the content
   description of the section
      [ OK ] whatever you want
--------------------------------------------------------------------------------
Commands: 2 out of 2 failed
Tests: 2 out of 3 failed
```
