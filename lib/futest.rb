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
      halt("#{v1} is #{v2}", nil, n) unless v1 == v2
    end

    # Greater than tester
    def gt(v1, v2, n = x(caller))
      halt("#{v1} gt #{v2}", nil, n) unless v1 > v2
    end

    # Less than tester
    def lt(v1, v2, n = x(caller))
      halt("#{v1} lt #{v2}", nil, n) unless v1 < v2
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
      halt(%{#{y.message}\n=> ~/#{$1.split('/')[3..-1].join('/')}}, nil, $2) if $1.present? and $2.present?
      halt(%{#{y.message}\n=> #{y.backtrace.join("\n")}})
    end

    # Get the line number
    def x(q)
      q.first.split(':')[1]
    end

  end
end
