require 'redis'

class RedisManager
  BASE_PORT = 20300

  class RedisServer
    attr_reader :port, :pid

    def initialize(port)
      @port = port
    end

    def ping?
      redis = ::Redis.connect(:host => '127.0.0.1', :port => port)
      redis.ping
      redis.quit
      return true
    rescue
      return false
    end

    def shutdown
      Process.kill('INT', @pid)
    end

    def start
      redis_config = <<-EOF
        daemonize no
        loglevel notice
        port #{port}
      EOF

      io = IO.popen('redis-server -', 'w')
      @pid = io.pid
      io.write redis_config

      raise "Could not start redis-server" unless $?.exitstatus == 0

      10.times do
        break if ping?
        sleep 0.25
      end
    end
  end

  def initialize(count)
    @servers = []
    start(count)
  end

  def start(count)
    count.times do |idx|
      @servers << RedisServer.new(BASE_PORT + idx)
    end

    @servers.each { |server| server.start }
  end

  def shutdown
    @servers.each { |server| server.shutdown }
  end
end