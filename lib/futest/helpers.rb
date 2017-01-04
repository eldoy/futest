module Futest
  module Helpers

    CMD = {
      :a? => 'is', :a => 'is',
      :eq => '==', :ne => '!=',
      :gt => '>',  :gte => '>=',
      :lt => '<',  :lte => '<=',
      :in => 'in', :nin => 'nin',
      :has => 'has'
    }

    ##############
    # TEST METHODS
    ##############

    # Prints error message and stops execution
    def stop(str, model = nil, n = line(caller))
      m = "#{n}: #{str}"

      # Support for errors when using Object DB ORM
      if model and model.errors and model.errors.any?
        q = model.errors.messages rescue model.errors
        m += ":\n=> " + q.each{|k, v| q[k] = v.join(', ')}.to_json[1..-2].gsub('","', '", "')
      end

      puts red(%{#{m}\n}); exit(0)
    end

    # Prints the test and runs setup methods
    def test(*args)
      n = args[-1].is_a?(Integer) ? args[-1] : line(caller)
      args.select{|r| r.is_a?(Symbol)}.each{|k| send(k)}
      puts green("#{n}: #{args[0]}")
    end

    # Equality tester
    def is(v1, v2 = :udef, n = line(caller))

      # Use :a? if v2 is not a string and looks like a class
      v2 = {:a? => v2} if !v2.is_a?(String) and v2.to_s[0] =~ /[A-Z]/

      # Use :eq if v2 is defined and it's not a Hash
      v2 = {:eq => v2} if v2 != :udef and !v2.is_a?(Hash)

      # Symbolize keys
      k, v = (v2.is_a?(Hash) ? v2 : {}).inject({}){|q,(k,v)|q[k.to_sym] = v; q}.to_a.flatten

      # Extract values
      s = ["#{v1.class} #{v1} #{CMD[k]} #{v.class} #{v}", nil, n]

      # Set @debug = true to print info
      puts s.join('-') if @debug

      # Stop unless true
      stop(*s) unless
      case k
      when nil then !!v1
      when :eq  then v1 == v
      when :ne  then v1 != v
      when :gt  then v1 > v
      when :gte then v1 >= v
      when :lt  then v1 < v
      when :lte then v1 <= v
      when :in  then v2[:in].include?(v1)
      when :nin then !v2[:nin].include?(v1)
      when :has then v1.has_key?(v2[:has])
      when :a?, :a then v1.is_a?(v)
      else false end
    end


    ##############
    # REQUEST HELPERS
    ##############

    # Pulls any data source and returns the response
    def pull(*args)
      # Define $host in your test helper
      # or @host before you call pull
      # set @base to add paths to @host
      @host ||= $host
      @base ||= ($base || '')
      stop('@host not defined') unless @host

      @method = args[0].is_a?(Symbol) ? args.delete_at(0) : :get
      @path = (args[0] || '/')
      @params = (args[1] || {})
      @headers = (args[2] || {})
      @headers.merge!(:cookies => @cookies) if @cookies

      args.each do |a|
        @params.merge!(a) if a.is_a?(Hash)
        @method = a if a.is_a?(Symbol)
        @path = a if a.is_a?(String)
      end

      # Add host and base to url
      @url = @host + (@base || '') + @path

      o = {
        :method => @method,
        :url => @url,
        :timeout => 2,
        :payload => @params,
        :headers => @headers
      }
      RestClient::Request.execute(o){|z| @page = z}
      # Make result available in instance variables
      [:code, :cookies, :headers, :history].each{|i| instance_variable_set("@#{i}", @page.send(i))}
      @raw = @page.raw_headers
      @body = @page.body
    end

    # Show the last @body in the browser
    def show
      stop('@body is not defined') unless @body

      # Add @host and @base to all links in HTML to fetch CSS and images
      @body.scan(/(<.*(src|href)=["'](\/?.+)["'].*>)/).each do |m|
        @body.gsub!(m[0], m[0].gsub(m[2], "#{@host}#{@base}#{m[2][0] == '/' ? m[2] : "/#{m[2]}"}")) unless %w[ht //].include?(m[2][0..1])
      end

      # Write body to tmp file
      name = "/tmp/#{Time.now.to_i}_fushow.html"
      File.open(name, 'w'){|f| f.write(@body)}

      # Open with default browser, set Futest.show to change this
      `#{Futest.show} #{name}`
    end


    ##############
    # HELPER METHODS
    ##############

    # Colorize output, 33 is :green (default), 31 is :red
    def out(s, c = :green)
      z = {:green => 33, :red => 31}; %{\e[#{z[c] || c}m#{s}\e[0m}
    end

    # Colorize input green
    def green(s); out(s); end

    # Colorize input red
    def red(s); out(s, :red); end

    # Print error message
    def err(*args)
      x = args[0]

      # Pass :v or :vv to print more information about the error
      puts x.backtrace.join("\n") if args.include?(:vv)
      puts x.message if args.include?(:v)

      # Normally just print the first line in the message
      x.backtrace.first.match(/(\/.+\/.*.rb):(\d{1,9}):/)
      stop(%{#{x.message}\n=> ~/#{$1.split('/')[3..-1].join('/')}}, nil, $2) if $1 and $2

      # Print more if the backtrace doesn't match
      stop(%{#{x.message}\n=> #{x.backtrace[0..60].join("\n")}})
    end

    # Get the line number
    def line(q)
      q.first.split(':')[1]
    end

  end
end
