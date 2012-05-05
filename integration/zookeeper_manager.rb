require 'zk-server'

class ZookeeperManager
  BASE_PORT = 23000

  attr_reader :servers

  def initialize(count)
    @servers = []
    start(count)
  end

  def start(count)
    zoo_cfg_hash = {}
    count.times do |idx|
      zoo_cfg_hash["server.#{idx}"] = "127.0.0.1:#{BASE_PORT + 100 + idx}:#{BASE_PORT + 200 + idx}"
    end

    zoo_cfg_hash['initLimit'] = '10'
    zoo_cfg_hash['syncLimit'] = '5'

    count.times do |idx|
      @servers << ZK::Server.new do |config|
        config.myid = idx
        config.base_dir = File.expand_path("../data/zookeeper-#{idx}", __FILE__)
        config.client_port = BASE_PORT + idx
        config.force_sync = false
        config.zoo_cfg_hash = zoo_cfg_hash
      end
    end

    @servers.each { |server| server.run }
  end

  def shutdown
    @servers.each { |server| server.clobber! }
  end
end