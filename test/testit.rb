require 'rubygems'
require 'bundler/setup'
require 'block_builder'


# As a convention, you should always document a block builder method and let consumers of
# this method know how to use it!
# @example
#   # Here is a code sample on how to use this method, etc
def create_remote_user(username, password, &block)
  builder = BlockBuilder.build block do
    set :logger, Logger.new
    
    # You can force the creation of a callback using the abstract operator. By default,
    # without the abstract modifier, calling an undefined callback will simply do nothing
    abstract :on_user_created
  end
  
  # If any callbacks label as 'abstract' aren't defined, then code execution will
  # never reach this line.
  
  # Here, you may first want to create the user and create a callback. This callback
  # can then be used to quickly save an entry in the database before other operations
  # are executed. This is useful, for example, if the server crashes during the middle
  # of the request or there is a bug later in the method call. This way, at least you
  # have the user information saved in your local database and you can retrieve the
  # user information later.
  result = api.create_user username, password
  builder.on_user_created(result)

  # Now we can keep on executing methods and have somewhere else take care of it. Using
  # the set logger variable, we can allow someone to externally change the logger used.
  #
  # Now what if the connection timed out here? Or the server crashed? That's the point
  # of the earlier callback! It allows you to save partial data without interfering
  # with the internal logic of this method!
  start = Time.now
  result2 = api.some_very_time_intensive_call_involving(username)
  builder.logger.info "Executed time intensive call in #{Time.now - start} sec!"
  builder.on_finish_lengthy_task.call(result2)
  
  # Another fun use for this: collecting statistics! It might be useful to collect a
  # bunch of statistics for a particular task. However, not every consumer of your
  # method will care for statistics. Just for fun, let's only calculate some
  # statistics about this method call only if they care to calculate stats!
  #
  # We use 'builder.defined?' here because doing
  #
  #   builder.generate_statistics.call(some_lengthy_statistic_compilation)
  #
  # will compile statistics, regardless of whether 'generate_statistics' is defined.
  if builder.defined? :generate_statistics
    stats = some_lengthy_statistic_compilation
    builder.generate_statistics.call(stats)
  end
  
  
  # Now you can add any more callbacks as you see fit! And don't forget, you can still
  # return some data from this method call if you want!
end


create_remote_user 'user', 'password' do
  
  # This easily lets us use our Rails logger
  set :logger, Rails.logger
  
  # Remember, our abstract callback was declared, so we must define it here. In this
  # case, assume we have a Ruby on Rails model that deals with saving saved data
  on_user_created do |result|
    u = RemoteUser.new(result)
    u.some_misc_operations
    u.save!
  end
end


# Assume this is some benchmark suite or testing file
create_remote_user 'user', 'password' do
  on_user_created do |result|
    # .. Implement here
  end
  
  # In this case, we might enjoy statistics
  generate_statistics do |stats|
    puts "Statistics for this operation:"
    puts " * Total execution time: #{stats.exec_time}"
    puts "..."
  end
  
end



puts "Testing!"
def test(&block)
  builder = BlockBuilder.build block do
    abstract :my_method
  end
  builder.my_method.call
end