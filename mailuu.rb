#!/usr/bin/ruby

require 'rubygems'
require 'mail'
require 'thor'
require 'yaml'
require 'yaml/store'

class Mailuu < Thor
  package_name 'Mailuu'
  map "-c" => :config
  map "-d" => :deliver

  DEFAULT_CONFIG = {
              :address              => "smtp.gmail.com",
              :port                 => 587,
              :domain               => 'localhost',
              :user_name            => '<your username>',
              :password             => '<your password>',
              :authentication       => 'plain',
              :enable_starttls_auto => true  }

  desc "config", "Creates a default config.store file for your smtp configuration. Usage: mailuu config."
  def config
    DEFAULT_CONFIG.each do |k,v|
      store_yaml(k,v)
    end
  end

  desc "deliver", "Sends email message. Usage: mailuu -d <to> <from> <subject> <body>"
  def deliver(recipient, sender, title, content)
    load_defaults
    Mail.deliver do
           to recipient
         from sender
      subject title
         body content
    end
  end

private
  def read_yaml
    YAML.load_file("./config.yml") rescue puts "No config file. Run mailuu -c"
  end

  def store_yaml(key, value)
    store = YAML::Store.new "config.yml"

    store.transaction do
      store[key] = value
    end
  end

  def load_defaults
    options = read_yaml
    Mail.defaults do
      delivery_method :smtp, options
    end
  end
end

Mailuu.start