require 'csv'
require 'pry'

hash = {}
index = 0

def hist_key_list(keys)
  # vendid,item,invoice,expped,entityid,ref,acctnum,itemamt,checkdt,checkno,checkpd,ckcashglref,addldesc
  # vendid,item,invoice,expped
  "#{keys[0]}+#{keys[1]}+#{keys[2]}+#{keys[3]}"
end

def ghis_key_list(keys)
  # item,acctnum,period,ref,entityid,source,amt,pdentry,descrpn,addldesc,basis
  # item,period,ref
  "#{keys[0]}+#{keys[2]}+#{keys[3]}"
end

CSV.foreach(ARGV[0]) do |row|
  puts index if index %100 == 0
  index += 1
  key_string = ARGV[1] ? hist_key_list(row) : ghis_key_list(row)
  next if key_string.gsub('+', '').size == 0
  if hash[key_string]
    binding.pry
  end
  hash[key_string] = 1
end

