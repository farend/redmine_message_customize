# redmine_message_customize

This is a plugin for Redmine.  
This plugin changes the translation of the wording on the screen defined in "config/locales/*.yml" in the admin view.

* Normal mode
<kbd><img src="https://github.com/ishikawa999/redmine_message_customize/blob/images/normal_mode.png" /></kbd>

* YAML mode
<kbd><img src="https://github.com/ishikawa999/redmine_message_customize/blob/images/yaml_mode.png" /></kbd>

## Install

```
$ cd /your/path/redmine/plugins
$ git clone https://github.com/ishikawa999/redmine_message_customize.git
$ # redmine restart
```

## Run test

```
$ cd /your/path/redmine
$ bundle exec rake test TEST=plugins/redmine_message_customize/test RAILS_ENV=test
```