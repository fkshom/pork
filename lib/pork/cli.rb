require 'thor'
require 'pp'
require 'yaml'

module Pork
  class CLI < Thor
    desc "gen", "gen"
    def gen()
      repository = Pork::Repository.new()
      repository.load_dir('sampledata')

      networks = yaml.load(File.read('sampledata/networks.yml'))
      networks['vds'].each{|network|
        pgname = network['pgname']
        address = [network['address']].flatten
        module = network['module']
        router = Pork::Vds.new( repository, pgname )
        address.each{|address|
          router.assign_host(address: address)
        }
        rules = router.create_rules()
        pp rules.to_h
      }
    end
  end
end
