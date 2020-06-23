require "option_parser"

file = ""
user = ""
domain = ""
service = ""
resource = ""

# Command line options
OptionParser.parse(ARGV.dup) do |parser|
  parser.banner = "Usage: #{PROGRAM_NAME} [arguments]"

  parser.on("-f FILE", "--file=FILE", "path to the auth.json file") do |f|
    file = f
  end

  parser.on("-u EMAIL", "--user=EMAIL", "a user account for checking calendar access") do |e|
    user = e
  end

  parser.on("-d DOMAIN", "--domain=DOMAIN", "the domain to be administered") do |d|
    domain = d
  end

  parser.on("-a EMAIL", "--admin=EMAIL", "the service user") do |e|
    service = e
  end

  parser.on("-r EMAIL", "--resource=EMAIL", "a resource calendar email") do |e|
    resource = e
  end

  parser.on("-h", "--help", "Show this help") do
    puts parser
    exit 0
  end
end

require "google"

if file.empty?
  puts "requires `-f ./auth.json` argument"
  exit 1
end

checked = [] of String

if !service.empty? && !domain.empty?
  begin
    auth = Google::FileAuth.new(file, scopes: "https://www.googleapis.com/auth/admin.directory.user.readonly", sub: service, user_agent: "PlaceOS Staff API")
    dir = Google::Directory.new(auth, domain)
    dir.users("steve").users.size
    checked << "✔ service user"
  rescue error
    puts error.inspect_with_backtrace
    puts error.as(Google::Exception).http_body if error.is_a?(Google::Exception)
    checked << "⨯ service user can't list users"
  end
else
  checked << "? service user not checked"
end

if !user.empty?
  begin
    auth = Google::FileAuth.new(file, scopes: "https://www.googleapis.com/auth/calendar", sub: user, user_agent: "PlaceOS Staff API")
    cal = Google::Calendar.new(auth: auth)
    cal.calendar_list.size
    checked << "✔ lists user calendars"
  rescue error
    puts error.inspect_with_backtrace
    puts error.as(Google::Exception).http_body if error.is_a?(Google::Exception)
    checked << "⨯ could not list users calendars"
  end
else
  checked << "? user calendar listing not checked"
end

if !user.empty? && !resource.empty?
  now = Time.utc
  start = now.at_beginning_of_day
  ending = now.at_end_of_day

  begin
    auth = Google::FileAuth.new(file, scopes: "https://www.googleapis.com/auth/calendar", sub: user, user_agent: "PlaceOS Staff API")
    cal = Google::Calendar.new(auth: auth)
    cal.events(
      resource,
      start,
      ending,
      showDeleted: true
    ).items.size
    checked << "✔ resource calendar events"
  rescue error
    puts error.inspect_with_backtrace
    puts error.as(Google::Exception).http_body if error.is_a?(Google::Exception)
    checked << "⨯ resource calendar event listing failed"
  end
else
  checked << "? resource calendar not checked"
end

puts "\n\nchecked:"
checked.each { |result| puts result }
puts "\n"
