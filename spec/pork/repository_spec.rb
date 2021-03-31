require "spec_helper"
require 'pathname'

RSpec.describe Pork::Repository::Rule do
  it "to_h" do
    src = Pork::Repository::Host.new(name: "192.168.0.1/32", address: "192.168.0.1/32")
    dst = Pork::Repository::Host.new(name: "192.168.0.1/32", address: "192.168.0.1/32")
    srcport = Pork::Repository::Port.new(name: "32768-65535", port: "32768-65535")
    service = Pork::Repository::Service.new(name: "53/udp", service: "53/udp")
    rule = Pork::Repository::Rule.new(
      src: src,
      dst: dst,
      srcport: srcport,
      service: service,
      action: 'accept',
    )
    expect(rule.to_h).to eq({
      src: src,
      dst: dst,
      srcport: srcport,
      service: service,
      action: 'accept',
    })
  end
end

RSpec.describe Pork::Repository do
  it "add rule" do
    repository = Pork::Repository.new()
    repository.add_rule(
      src: '192.168.11.0/24',
      dst: '192.168.12.11/32',
      srcport: '32768-65535',
      service: '53/udp',
      action: 'accept',
      target: '.*',
    )
    actual = repository.rules[0]
    expect(actual.src.class).to eq Pork::Repository::Host
    expect(actual.src.name).to eq "192.168.11.0/24"
    expect(actual.src.address).to eq "192.168.11.0/24"
    expect(actual.dst.class).to eq Pork::Repository::Host
    expect(actual.dst.name).to eq "192.168.12.11/32"
    expect(actual.dst.address).to eq "192.168.12.11/32"
    expect(actual.srcport.class).to eq Pork::Repository::Port
    expect(actual.srcport.name).to eq "32768-65535"
    expect(actual.srcport.port).to eq "32768-65535"
    expect(actual.service.class).to eq Pork::Repository::Service
    expect(actual.service.name).to eq "53/udp" 
    expect(actual.service.port).to eq "53"
    expect(actual.service.protocol).to eq "udp"
    expect(actual.action).to eq "accept"
    expect(actual.target.to_s).to eq '(?-mix:.*)'
  end
end
