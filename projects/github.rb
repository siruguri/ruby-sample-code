require 'pry'
require 'github_api'

class Tracker
  attr_reader :open_details, :today, :client, :token, :closed_details

  def initialize
    @token = ARGV[0]
    @open_details = []
    @closed_details = []
    @client = Github::Client::Issues.new oauth_token: token
    @today = DateTime.now
  end

  def open?(i)
    i.closed_at.nil?
  end

  def has_label?(i, label)
    i.labels.select { |l| l.name.to_sym == label }.size > 0
  end

  def run
    page_available = true
    page_num = 1

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
            open_details << {number: i.number, title: i.title, created_at: gap.to_f}
          else
            closed_at = DateTime.strptime(i.closed_at, '%Y-%m-%dT%H:%M:%SZ')
            gap = (closed_at - created_at).to_i
            closed_details << {number: i.number, title: i.title, closed_in: gap.to_f}
          end
        end
      end
    end

    self
  end

  def print_details(params)
    params.each do |param|
      puts "## #{param.upcase}"
      next if !self.respond_to?(param)
      self.send(param).each do |detail|
        print "\t"
        print "##{detail[:number]} (#{detail[:title]}) - "
        if detail[:closed_in]
          print "closed in #{detail[:closed_in]}"
        elsif detail[:created_at]
          print "opened on #{detail[:created_at]}"
        end
        puts
      end
    end

    self
  end
end

Tracker.new.run.print_details [:open_details]
