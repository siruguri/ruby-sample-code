require 'benchmark'

class Candidates
  def initialize
    @hash = {}
    1.upto(10000).each do |n|
      @hash["#{n}"] = n
    end
    @rev = {}
  end
  def patt1
    @rev[@hash['a']+ 'num'] = @hash['a']
    @rev[@hash['a']+ 'str'] = @hash['a'].to_i
  end
  def patt2 x
    key = @hash['a']
    @rev[key + 'num'] = key
    @rev[key + 'str'] = key.to_i
  end

  def check_key1
    @hash.keys.include?('a')
  end

  def check_key2
    !@hash['a'].nil?
  end
end

n = 1000000
c = Candidates.new

Benchmark.bmbm do |x|
  x.report { c.check_key1 }
  x.report { c.check_key2 }
end
