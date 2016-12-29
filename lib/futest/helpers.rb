module Futest
  module Helpers

    ##############
    # TEST METHODS
    ##############

    # Prints error message and stops execution
    def stop(str, obj = nil, n = line(caller))
      m = "#{n}: #{str}"
      # Support for errors when using Object DB ORM
      if obj and obj.errors and obj.errors.any?
        q = obj.errors.messages rescue obj.errors
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
    def is(v1, v2, n = line(caller))
      # Adding some flexibility
      v2 = {:a? => v2} if !v2.is_a?(String) and v2.to_s[0] =~ /[A-Z]/
      v2 = {:eq => v2} if !v2.is_a?(Hash)

      # For key output
      def fs(y);{
        :a? => 'is',
        :a => 'is',
        :eq => '==',
        :ne => '!=',
        :gt => '>',
        :gte => '>=',
        :lt => '<',
        :lte => '<=',
        :in => 'in',
        :nin => 'nin',
        :has => 'has'
      }[y] rescue y; end

      # Symbolize keys and extract values
      k, v = v2.inject({}){|q,(k,v)|q[k.to_sym] = v; q}.to_a.flatten
      s = ["#{v1.class} #{v1} #{fs(k)} #{v.class} #{v}", nil, n]

      stop(*s) unless
      case k
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
      @page = RestClient::Request.execute(o)

      # Make result available in instance variables
      [:code, :cookies, :headers, :history].each{|i| instance_variable_set("@#{i}", @page.send(i))}
      @raw = @page.raw_headers
      @body = @page.body
    end

    # Show the last @body in the browser
    def show
      stop('@body is not defined') unless @body

      # Add @host and @base to all links in HTML to fetch CSS and images
      @body.scan(/(<.*(src|href)=["'](\/.+)["'].*>)/).each do |m|
        @body.gsub!(m[0], m[0].gsub(m[2], "#{@host}#{@base}#{m[2]}"))
      end

      # Write body to tmp file
      name = "/tmp/#{Time.now.to_i}_fushow.html"
      File.open(name, 'w'){|f| f.write(@body)}

      # Open with default browser (MacOS)
      `open -g #{name}`
    end


    ##############
    # HELPER METHODS
    ##############

    # Colorize input red
    def red(text);"\e[31m#{text}\e[0m";end

    # Colorize input green
    def green(text);"\e[33m#{text}\e[0m";end

    # Print error message
    def err(y)
      y.backtrace.first.match(/(\/.+\/.*.rb):(\d{1,9}):/)
      stop(%{#{y.message}\n=> ~/#{$1.split('/')[3..-1].join('/')}}, nil, $2) if $1 and $2
      stop(%{#{y.message}\n=> #{y.backtrace.join("\n")}})
    end

    # Get the line number
    def line(q)
      q.first.split(':')[1]
    end

  end
end
