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
end

