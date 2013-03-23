BlockBuilder
============
Make callbacks easily and build blocks with ease! BlockBuilder is intended to be used with more heavy weight method calls that might require intermediate callbacks. It's almost like creating classes on the fly!

## Usage
Some code samples to get you started:

### File Download Example
Downloading a file probably doesn't merit the block builder, but it demonstrates the concept of callbacks.

```ruby
def download_file(url, &block)
  
  # Configure your block here, along with defaults
  builder = BlockBuilder.build block do
    
    # Set optional default variables!
    set :verbose, true
    
    on_fail do |http_code, body|
      puts "Oh no! HTTP download failed! Code: #{http_code}"
      puts "Downloaded body: #{body}" if verbose
    end
    
    on_success do |body|
      puts "Downloaded file Successfully!"
    end
  end
  
  # Now execute your blocks! Note you don't have to explicitly
  # define any of your callbacks.
  result = download_some_file_from_internet(url)
  if result.http_code == 200
    builder.on_success.call result.body
  else
    builder.on_fail.call result.http_code, result.body
  end
  
end


# Now you can call the method above and change the defaults!
download_file "example.com/exists.txt" do
  on_success do |body|
    File.open('some/file.txt', 'w') {|f| f.write body }
  end
end

# Only outputs "Oh no! HTTP download failed! Code: 404"
download_file "example.com/doesnotexist.txt" do
  set :verbose, false
end
```

### Callbacks and Remote Data
Sometimes you might connect to another service or API that contains critical information. And perhaps you need to query multiple times with this API to get the data you need. Callbacks can help with this!

```ruby
 As a convention, you should always document a block builder method and let consumers of
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
  builder.on_user_created.call(result)

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
```

Now you can use this method in multiple places. Here, assume this is where the code is primarily used:

```ruby
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
```

Finally, assume this is some benchmark suite, or something else:

```ruby
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
```



## Installation

Add this line to your application's Gemfile:

    gem 'blockbuilder'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install blockbuilder

