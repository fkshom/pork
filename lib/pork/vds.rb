require 'forwardable'
require 'pork/generators/vds_rules'

class Pork::Vds
  # ビジネスロジックを含むクラス
  # リポジトリとfilter 定義をつなぐ役割を持つ
  # 次のルールを利用する
  # - 自機のinterfaceをdstとするルールを利用する
  # - 自機のinterfaceをsrcとするルールの戻りを利用する
  # ルールの自動集約は行わない

  extend Forwardable
  def_delegators :@engine, :add_rule
  
  def initialize(repository, pgname)
    @engine = Pork::Generators::VdsRules.new(pgname)
    @repository = repository
    @pgname = pgname
    @having_hosts = []
  end

  def assign_host(address:)
    @having_hosts << address
  end
  
  def normalize_host(host)
    if host.name == 'any'
      return nil
    else
      return host.address
    end
  end

  def normalize_port(port)
    if port.name == 'any'
      return nil
    else
      return port.port
    end
  end

  def normalize_service(service)
    if service.name == 'any'
      return [nil, nil]
    else
      return [service.port, service.protocol]
    end
  end

  def dst_of_the_rule_is_my_portgroup(rule)
    rule.dst.name == 'any' or @having_hosts.any?{|host| IPAddr.new(host).include?(IPAddr.new(rule.dst.address)) }
  end
  
  def src_of_the_rule_is_my_portgroup(rule)
    rule.src.name == 'any' or @having_hosts.any?{|host| IPAddr.new(host).include?(IPAddr.new(rule.src.address)) }
  end

  def create_rules
    @repository.rules.select{|rule| rule.target =~ @pgname}.each do |rule|
      if src_of_the_rule_is_my_portgroup(rule)
        # 自PortGroupのアドレスがsrcであるルールである
        if rule.src.name == 'any'
          dst = nil
        else
          dst = rule.src.address
        end
        src = normalize_host(rule.dst)
        dstport = normalize_port(rule.srcport)
        srcport, protocol = normalize_service(rule.service)

        @engine.add_rule(
          description: "#{rule[:action][0].upcase}_#{rule.src.name}_#{rule.dst.name}",
          src: src, dst: dst, srcport: srcport, dstport: dstport,
          protocol: protocol, action: rule[:action])

        # 自PortGroupのアドレスがsrcであるルールの戻りを抽出する
        @engine.add_rule(
          description: "#{rule[:action][0].upcase}_#{rule.src.name}_#{rule.dst.name}_RET",
          src: dst, dst: src, srcport: dstport, dstport: srcport,
          protocol: protocol, action: rule[:action])
      end

      if  dst_of_the_rule_is_my_portgroup(rule)
        # 自PortGroupのアドレスがdstであるルールである
        if rule.dst.name == 'any'
          dst = nil
        else
          dst = rule.dst.address
        end
        src = normalize_host(rule.src)
        srcport = normalize_port(rule.srcport)
        dstport, protocol = normalize_service(rule.service)
        @engine.add_rule(
          description: "#{rule[:action][0].upcase}_#{rule.src.name}_#{rule.dst.name}",
          src: src, dst: dst, srcport: srcport, dstport: dstport,
          protocol: protocol, action: rule[:action])
        @engine.add_rule(
          description: "#{rule[:action][0].upcase}_#{rule.src.name}_#{rule.dst.name}_RET",
          src: dst, dst: src, srcport: dstport, dstport: srcport,
          protocol: protocol, action: rule[:action])
      end


      # # 自PortGroupのアドレスがdstであるルールを抽出する
      # if rule.dst.name == 'any'
      #   dst = nil
      # else
      #   if @having_hosts.any?{|host| IPAddr.new(host).include?(IPAddr.new(rule.dst.address)) }
      #     dst = rule.dst.address
      #   else
      #     next
      #   end
      # end
      # src = normalize_host(rule.src)
      # srcport = normalize_port(rule.srcport)
      # dstport, protocol = normalize_service(rule.service)

      # @engine.add_rule(
      #   description: "#{rule[:action][0].upcase}_#{rule.src.name}_#{rule.dst.name}",
      #   src: src, dst: dst, srcport: srcport, dstport: dstport,
      #   protocol: protocol, action: rule[:action])
    
      # # 自PortGroupのアドレスがsrcであるルールの戻りを抽出する
      # if rule.src.name == 'any'
      #   dst = nil
      # else
      #   if @having_hosts.any?{|host| IPAddr.new(host).include?(IPAddr.new(rule.src.address)) }
      #     dst = rule.src.address
      #   else
      #     next
      #   end
      # end
      # src = normalize_host(rule.dst)
      # dstport = normalize_port(rule.srcport)
      # srcport, protocol = normalize_service(rule.service)

      # @engine.add_rule(
      #   description: "#{rule[:action][0].upcase}_#{rule.src.name}_#{rule.dst.name}_RET",
      #   src: src, dst: dst, srcport: srcport, dstport: dstport,
      #   protocol: protocol, action: rule[:action])
    end
    @engine.rules
  end     
end
