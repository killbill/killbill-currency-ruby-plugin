require 'bundler'
require 'logger'
require 'rspec'

require 'currency_plugin'

RSpec.configure do |config|
  config.color_enabled = true
  config.tty = true
  config.formatter = 'documentation'
end

class Object
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end
end


require 'active_record'

#ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :database => 'test.db'
)
# Create the schema
require File.expand_path(File.dirname(__FILE__) + '../../db/schema.rb')
