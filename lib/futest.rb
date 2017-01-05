require 'rest-client'
require 'json'

module Futest

  # # # # # #
  # Futest flexible testing helpers for Ruby
  # @homepage: https://github.com/fugroup/futest
  # @author:   Vidar <vidar@fugroup.net>, Fugroup Ltd.
  # @license:  MIT, contributions are welcome.
  # # # # # #

  class << self; attr_accessor :show, :mode, :debug; end

  # The command to run when you use 'show'
  # The default is for MacOs. The -g flag opens the page in the background.
  @show = 'open -g'

  # Mode, default is development
  @mode = ENV['RACK_ENV'] || 'development'

  # Debug
  @debug = false
end

require_relative 'futest/helpers'
