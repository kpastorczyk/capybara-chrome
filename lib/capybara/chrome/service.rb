module Capybara::Chrome
  module Service

    def start_chrome
      return if chrome_running?
      info "Starting Chrome", chrome_path, chrome_args
      @chrome_pid = Process.spawn chrome_path, *chrome_args
      at_exit { stop_chrome }
    end

    def stop_chrome
      Process.kill "TERM", @chrome_pid rescue nil
    end

    def wait_for_chrome
      running = false
      while !running
        running = chrome_running?
        sleep 0.02
      end
    end

    def chrome_running?
      socket = TCPSocket.new(@chrome_host, @chrome_port) rescue false
      socket.close if socket
      !!socket
    end

    def chrome_path
      case os
      when :macosx
        "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
      when :linux
        # /opt/google/chrome/chrome
        "google-chrome"
      end
    end

    def chrome_args
      ["--remote-debugging-port=#{@chrome_port}", "--headless", "--crash-dumps-dir=/tmp"]
    end

    def os
      @os ||= (
        host_os = RbConfig::CONFIG['host_os']
        case host_os
        when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
          :windows
        when /darwin|mac os/
          :macosx
        when /linux/
          :linux
        when /solaris|bsd/
          :unix
        else
          raise Error::WebDriverError, "unknown os: #{host_os.inspect}"
        end
      )
    end

    def find_available_port(host)
      server = TCPServer.new(host, 0)
      server.addr[1]
    ensure
      server.close if server
    end

  end
end