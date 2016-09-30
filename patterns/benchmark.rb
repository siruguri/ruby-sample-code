require 'benchmark'

class Candidates
  def initialize
    @hash = {'a' => '5', 'b' => '10' }
    @rev = {}
  end
  def patt1
    @rev[@hash['a']+ 'num'] = @hash['a']
    @rev[@hash['a']+ 'str'] = @hash['a'].to_i
  end
  def patt2
    key = @hash['a']
    @rev[key + 'num'] = key
    @rev[key + 'str'] = key.to_i
  end
end

n = 100000
c = Candidates.new

Benchmark.bmbm do |x|
  x.report { c.patt1 }
  x.report { c.patt2 }
end
