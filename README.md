# redmine_message_customize

This is a plugin for Redmine.  
This plugin changes the translation of the wording on the screen defined in "config/locales/*.yml" in the admin view.

## Install

```
$ cd /your/path/redmine
$ git clone https://github.com/ishikawa999/redmine_message_customize.git plugins/redmine_message_customize
$ cp plugins/redmine_message_customize/35_change_load_order_locales.rb config/initializers/35_change_load_order_locales.rb
$ # redmine restart
```

:warning: In order to customize messages of other plugins, it is necessary to copy redmine_message_customize/35_change_load_order_locales.rb into redmine/config/initializers.  
If you don't have redmine/config/initializers/35_change_load_order_locales.rb, you can customize only messages other than plugins.

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
