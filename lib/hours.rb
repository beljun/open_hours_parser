$:.unshift File.dirname(__FILE__)
require 'hours/token.rb'
require 'hours/tagger.rb'
require 'hours/open_hours.rb'
require 'hours/chunker.rb'
require 'hours/parser.rb'

module Hours
  # Main entry point for this module.
  def self.parse(text)
    Parser.new().parse(text)
  end
end

