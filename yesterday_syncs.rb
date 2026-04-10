pt = ActiveSupport::TimeZone["America/Los_Angeles"]
tc = pt.now.yesterday.change(hour: 15)

rows =
  Sync
    .joins(:organization)
    .where("syncs.created_at > ?", tc)
    .group("syncs.organization_id", "organizations.subdomain")
    .select(
      "organizations.subdomain AS subdomain",
      "MIN(syncs.created_at) AS start_time",
      "MAX(syncs.created_at) AS end_time"
    )
    .order("organizations.subdomain ASC")

# 1) Per-subdomain output
rows.each do |r|
  puts "#{r.subdomain}: #{r.start_time.in_time_zone(pt)} - #{r.end_time.in_time_zone(pt)}"
end

puts "\nHourly active subdomains since #{tc} (PT)\n\n"

# Use the latest end_time among the rows (per-subdomain maxes), rounded down to the hour
latest_end = rows.map(&:end_time).compact.max
end_time = latest_end&.in_time_zone(pt)&.beginning_of_hour

if end_time.nil?
  puts "No rows found after #{tc}."
else
  # Hour buckets from 3pm PT yesterday through the hour of the latest end_time (PT)
  hours = []
  t = tc.beginning_of_hour
  while t <= end_time
    hours << t
    t += 1.hour
  end

  # Active for hour [h, h+1): overlap if (start < h+1hour) && (end >= h)
  hours.each do |h|
    h_end = h + 1.hour

    active_count = rows.count do |r|
      start_pt = r.start_time.in_time_zone(pt)
      end_pt   = r.end_time.in_time_zone(pt)
      start_pt < h_end && end_pt >= h
    end

    puts "#{h.strftime("%Y-%m-%d %H:00 PT")}: #{active_count}"
  end
end
