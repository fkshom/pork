require 'pp'
require 'yaml'
require 'active_support'
require 'active_support/core_ext'

module Pork::Generators
  class VdsRules
    attr_accessor :rules
    
    def initialize(pgname:)
      @pgname = pgname
      @rules = []
    end

    def add_rule(**kwargs)
      rule = kwargs.symbolize_keys
      @rules << {
          description: rule[:description],
          src: src = rule[:src].nil? ? 'any' : rule[:src],
          dst: dst = rule[:dst].nil? ? 'any' : rule[:dst],
          srcport: srcport = rule[:srcport].nil? ? 'any' : rule[:srcport],
          dstport: dstport = rule[:dstport].nil? ? 'any' : rule[:dstport],
          protocol: protocol = rule[:protocol].nil? ? 'any' : rule[:protocol],
          action: rule[:action]
        }
    end
  end
end
 