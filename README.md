# redmine_message_customize

This is a plugin for Redmine.  
This plugin changes the translation of the wording on the screen defined in "config/locales/*.yml" in the admin view.  
It is available for Redmine 6.0 or later.

## Install

```
$ cd /your/path/redmine
$ git clone https://github.com/farend/redmine_message_customize.git plugins/redmine_message_customize
$ # redmine restart
```

## Usage

* 1: Open setting page  
Administration > Message customize
<kbd><img src="https://github.com/farend/redmine_message_customize/blob/images/administration_menu.png" /></kbd>

* 2-1: Normal mode tab
<kbd><img src="https://github.com/farend/redmine_message_customize/blob/images/normal_mode.png" /></kbd>

* 2-2: YAML mode tab
<kbd><img src="https://github.com/farend/redmine_message_customize/blob/images/yaml_mode.png" /></kbd>

## Run test

```
$ cd /your/path/redmine
$ bundle exec rake redmine:plugins:test NAME=redmine_message_customize RAILS_ENV=test
```

----

2022/6/08 Transferred ownership of the repository from ishikawa999 to [Far End Technologies Corporation](https://github.com/farend).
