module CommonUtils

  @@help_string=""

  def self.set_help_string(s)
    @@help_string=s
  end

  def self.print_help_and_exit
    puts <<EOS
  #{__FILE__} [options]
  #{@@help_string}
EOS
  end

  def self.error_exit(msg)
    puts "ERROR: #{msg}"
    exit -1
  end

  def self.log_msg(msg)
    puts "#{msg}"
  end

  class Logger
    DEBUG=4
    INFO=3
    WARN=2
    ERROR=1
    FATAL=0

    def initialize(level)
      @mesg_level = level.to_i
    end

    def debug(mesg)
      self.puts mesg, DEBUG
    end

    def puts(mesg, level=DEBUG)
      if @mesg_level >= level
        super mesg
      end
    end
  end
end

