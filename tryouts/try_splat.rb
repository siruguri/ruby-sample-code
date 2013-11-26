def splatter(*opts, &proc)
  yield opts[0][:a]

  if opts[0][:a] < 3
    splatter(a: opts[0][:a]+1, b: 42) do |arg|
      proc.call(arg)
    end
  end
end

splatter(a: 1) do |x|
  puts "working #{x}"
end

