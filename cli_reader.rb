class CliReader
  attr_reader :args

  class RequiredParameterException < Exception
  end

  def initialize(args_list)
    # Typically args_list is the command line ARGV global
    @args = args_list
  end

  def parameter_argument(param, binary: false, default: nil, required: false)
    opt = args.each_with_index.select { |item, idx| item.strip == param }

    ret =
      if !binary
        (opt.size > 0 && opt.first[1] + 1 < args.size) ? args[opt.first[1] + 1] : default
      else
        opt.size > 0
      end

    if required && ret.nil?
      raise RequiredParameterException.new("#{param} was required but not supplied")
    end

    ret
  end
end

