# redmine_message_customize

This is a plugin for Redmine.  
This plugin changes the translation of the wording on the screen defined in "config/locales/*.yml" in the admin view.

## Install

```
$ cd /your/path/redmine
$ git clone https://github.com/ishikawa999/redmine_message_customize.git plugins/redmine_message_customize
$ # When Redmine 4.1 or lower versions
$ cp plugins/redmine_message_customize/35_change_load_order_locales.rb config/initializers/35_change_load_order_locales.rb
$ # redmine restart
```

:warning To customize messages for other plugins in **Redmine 4.1 or lower versions**, redmine_message_customize/35_change_load_order_locales.rb It is necessary to copy the file to redmine/config/initializers. 
If redmine/config/initializers/35_change_load_order_locales.rb is missing, only non-plugin messages can be customized.

## Usage

* 1: Open setting page  
Administration > Message customize
<kbd><img src="https://github.com/ishikawa999/redmine_message_customize/blob/images/administration_menu.png" /></kbd>

* 2-1: Normal mode tab
<kbd><img src="https://github.com/ishikawa999/redmine_message_customize/blob/images/normal_mode.png" /></kbd>

* 2-2: YAML mode tab
<kbd><img src="https://github.com/ishikawa999/redmine_message_customize/blob/images/yaml_mode.png" /></kbd>

## Run test

```
$ cd /your/path/redmine
$ bundle exec rake redmine:plugins:test NAME=redmine_message_customize RAILS_ENV=test
```

## CircleCI test

https://circleci.com/gh/ishikawa999/redmine_message_customize
