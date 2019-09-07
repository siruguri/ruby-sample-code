require 'pry'
require 'github_api'
token = ARGV[0]

client = Github::Client::Issues.new oauth_token: token

page_num = 1
page_available = true
today = DateTime.now

def open?(i)
  i.closed_at.nil?
end

def has_label?(i, label)
  i.labels.select { |l| l.name.to_sym == label }.size > 0
end

while(page_available)
  issues = client.list filter: 'all', repo: 'canopy', user: 'sunnyrjuneja', state: 'all',
                       page: page_num
  m = /page=(\d+)...rel..next/.match(issues.headers['Link'])
  if m.nil? || m[1].nil?
    page_available = false
  else
    page_num = m[1].to_i
  end
  issues.each do |i|
    created_at = DateTime.strptime(i.created_at, '%Y-%m-%dT%H:%M:%SZ')
    if has_label?(i, :bug)
      if open?(i)
        gap = (today - created_at).to_i
        puts "#{i.number}: #{i.title}, created #{gap.to_f} days ago"
      else
        closed_at = DateTime.strptime(i.closed_at, '%Y-%m-%dT%H:%M:%SZ')
        gap = (closed_at - created_at).to_i
        puts "#{i.number}: #{i.title}, closed in #{gap.to_f} days"
      end
    end
  end
end

