require 'pp'
require 'yaml'

module Pork::Generators
  class VdsRules
    def initialize(pgname:)
      @pgname = pgname
      @rules = {}
    end

    def add_rule(rule:)
      @rules << rule
    end

    def to_h
      result = []
      @rules.each do |obj|
        src = obj[:src].nil? ? 'any' : obj[:src]
        dst = obj[:dst].nil? ? 'any' : obj[:dst]
        srcport = obj[:srcport].nil? ? 'any' : obj[:srcport]
        dstport = obj[:dstport].nil? ? 'any' : obj[:dstport]
        protocol = obj[:protocol].nil? ? 'any' : obj[:protocol]
        result << {
          description: obj[:description],
          src: src, dst: dst,
          srcport: srcport, dstport: dstport,
          protocol: protocol, action: obj[:action]
        }
      end
      result
    end
  end
end
