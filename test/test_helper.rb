DIR = File.dirname(__FILE__)

# Loads the test environment. First try to load the Rails environment if we're
# in a Rails project. Otherwise just load the libraries that we need.
def load_environment
  begin
    test_helper = File.expand_path "#{DIR}/../../../../test/test_helper"
    puts "Loading #{test_helper}.rb ..."
    require test_helper 
  rescue LoadError
    puts "No Rails environment found"
    require 'rubygems'
    gem 'activerecord'
    gem 'actionpack'
    require 'active_record'
    require 'action_controller'
  end
end

# Setups the test database. Use an in-memory SQLite database.
def setup_database
  puts "Creating in-memory test database ..."
  ActiveRecord::Base.configurations = {
    'test' => { :adapter => 'sqlite3', :dbfile  => ':memory:' }
  } 
  ActiveRecord::Base.establish_connection 'test'
  load "#{DIR}/db/schema.rb" 
end

# -------------------------------------
# Main
# -------------------------------------
load_environment
setup_database
