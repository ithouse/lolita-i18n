require 'optparse'

module Lolita
  module I18n
    module Remake
      class << self
        def store_hash(subkeys, value)
          hsh = {}
          store_key_value(hsh, subkeys, value)
          hsh
        end

        def read_yaml_directory(locales_root_path, locale)
          hsh = {}
          file_paths = Dir["#{locales_root_path}/**/#{locale}.yml"]
          file_paths.each do |file_path|
            single_file_hsh = YAML.load(File.read(file_path))
            hsh.deep_merge!(single_file_hsh)
          end
          hsh
        end

        def write_yaml(hsh, file_path)
          File.open(file_path, 'w') do |file|
            file.write(hsh.to_yaml)
          end
        end

        def deeply_sort_hash(object)
          return object unless object.is_a?(Hash)
          hash = RUBY_VERSION >= '1.9' ? Hash.new : ActiveSupport::OrderedHash.new
          object.each { |k, v| hash[k] = deeply_sort_hash(v) }
          sorted = hash.sort { |a, b| a[0].to_s <=> b[0].to_s }
          hash.class[sorted]
        end

        private

        def store_key_value(hsh, subkeys, value)
          key = subkeys.slice!(0..0)[0]
          if subkeys.empty?
            hsh[key] = value
          else
            hsh[key] = {}
            store_key_value(hsh[key], subkeys, value)
          end
        end
      end
    end
  end
end

namespace :lolita_i18n do |args|
  desc "Export redis DB and merge with yml. args: -- --redisdb=1 --locale=lv --outfile=../lv.yml"
  task :export_redis => :environment do
    locales_root = File.join(Rails.root, 'config', 'locales')
    options = {}
    OptionParser.new(args) do |opts|
      opts.banner = "Usage: rake i18n:export_redis [options]"
      opts.on("-r", "--redisdb {number}","Redis database number", String) do |number|
        options[:redis_rb] = number
      end
      opts.on("-l", "--locale {locale}","Locale to export", String) do |lang|
        options[:locale] = lang
      end
      opts.on("-f", "--outfile {filename}","Output filename", String) do |filename|
        options[:filename] = filename
      end
    end.parse!
    store = Redis.new(:db => options[:redis_rb])
    keys = store.keys("#{options[:locale]}.*").sort
    new_i18n = {}
    keys.each do |key|
      subkeys = key.split('.')
      value = store.get(key)
      if value.match(/^{/) || value.match(/^\[/)
        value = JSON.parse(value)
      else
        value.gsub!(/\bnull\b/, 'nil')
        value = eval(value)
      end
      new_i18n.deep_merge!(Lolita::I18n::Remake.store_hash(subkeys, value))
    end
    file_i18n_path = File.join(locales_root, "#{options[:locale]}.yml")
    file_i18n = YAML.load(File.read(file_i18n_path))
    file_i18n.deep_merge!(new_i18n)
    Lolita::I18n::Remake.deeply_sort_hash(file_i18n)
    Lolita::I18n::Remake.write_yaml(file_i18n, options[:filename])
  end
end

