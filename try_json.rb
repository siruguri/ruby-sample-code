require 'json'

f=File.open(ARGV[0])

json_d = JSON.parse f.readline

def recurse_proc(result, *opts, &proc)
  # If opts wasn't passed in, initialize it. We are at the top of the recursion.
  if opts[0].nil?
    opt_hash={}
  else
    opt_hash=opts[0]
  end

  opt_hash[:level] ||= 0
  opt_hash[:parent_name] ||= ""

  case result
  when Array
    yield result, level: opt_hash[:level], parent_name: opt_hash[:parent_name]
    result.each { |x| recurse_proc x, level: opt_hash[:level]+1, parent_name: opt_hash[:parent_name], 
      &proc }
  when Hash
    yield result, level: opt_hash[:level], parent_name: opt_hash[:parent_name]
    result.each { |x, y| recurse_proc(y, level: opt_hash[:level]+1, parent_name: result['title'], &proc) if x=='children' }
  end
end

parent_name=""
recurse_proc(json_d, level: 0) do |x, *opts|
  opt_hash = opts[0]
  puts opt_hash.class

  if x.instance_of? Hash
    # Print all of its keys at this level
    x.each do |k, v|
      if k != 'children' then
        opt_hash[:level].times { print " " }
        print "#{k}:#{v}"

        if k == 'title' then # Print the parent name
          print " (#{opt_hash[:parent_name]})"
        end

        puts
      end
    end

    # Set the parent if necessary
    if x['type'] == 'text/x-moz-place-container' then
      opt_hash[:parent_name]=x['title']
      puts ">> Set new parent #{opt_hash[:parent_name]}"
    end

  elsif x.instance_of? Array # or x.instance_of? Hash
    opt_hash[:level].times { print " " }
    puts "-->"
  end
end
