# frozen_string_literal: true

require 'json'
require 'json-schema'
require 'rubygems'
require 'bundler'
require 'fileutils'

Bundler.setup :default, :development

load 'tasks/download.rake'
load 'tasks/events.rake'
load 'tasks/methods.rake'
load 'tasks/validate.rake'
load 'tasks/update.rake'

task default: 'api:update'
