module Futest
  module Helpers

    ##############
    # TEST METHODS
    ##############

    # Prints error message and stops execution
    def halt(str, obj = nil, n = x(caller))
      m = "#{n}: #{str}"
      if obj and obj.errors.any?
        n = obj.errors.messages
        m += ":\n=> " + n.each{|k, v| n[k] = v.join(', ')}.to_json[1..-2].gsub('","', '", "')
      end
      puts red(%{#{m}})
      puts
      exit(0)
    end

    # Prints the test and runs setup methods
    def test(*args)
      n = args[-1].is_a?(Integer) ? args[-1] : x(caller)
      args.select{|r| r.is_a?(Symbol)}.each{|k| send(k)}
      puts green("#{n}: #{args[0]}")
    end

    # Equality tester
    def is(v1, v2, n = x(caller))
      v2 = {:eq => v2} unless v2.is_a?(Hash)
      # Extract options here with delete.
      # No options available at the moment.

      # For key output
      def fs(y);{:eq => '==', :gt => '>', :lt => '<', :a? => 'is a'}[y] rescue y;end

      # Symbolize keys and extract values
      k, v = v2.inject({}){|q,(k,v)|q[k.to_sym] = v; q}.to_a.flatten
      s = ["#{v1.class} #{v1} #{fs(k)} #{v}", nil, n]
      case k
      when :eq
        halt(*s) unless v1 == v
      when :gt
        halt(*s) unless v1 > v
      when :lt
        halt(*s) unless v1 < v
      when :a?
        halt(*s) unless v1.is_a?(v)
      else
        puts "#{k}: Command not supported."
      end
    end

    ##############
    # HELPER METHODS
    ##############

    # Colorize input red
    def red(text);"\e[31m#{text}\e[0m";end

    # Colorize input green
    def green(text);"\e[33m#{text}\e[0m";end

    # Print error message
    def e(y)
      y.backtrace.first.match(/(\/.+\/.*.rb):(\d{1,9}):/)
      halt(%{#{y.message}\n=> ~/#{$1.split('/')[3..-1].join('/')}}, nil, $2) if $1 and $2
      halt(%{#{y.message}\n=> #{y.backtrace.join("\n")}})
    end

    # Get the line number
    def x(q)
      q.first.split(':')[1]
    end

  end
end
