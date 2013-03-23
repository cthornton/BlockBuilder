BlockBuilder
============
Make callbacks easily and build blocks with ease! BlockBuilder is intended to be used with more heavy weight method calls that might require intermediate callbacks. It's almost like creating classes on the fly!

## Usage
The most basic usage:

	```ruby
    # Sample method to download from the internet
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
      
      # Now execute your blocks!
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

## Installation

Add this line to your application's Gemfile:

    gem 'blockbuilder'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install blockbuilder

