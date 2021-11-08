require 'faraday'
require 'json'

url = ARGV[0]
interval = ARGV.fetch(1,10).to_i
loop do
  customers = JSON.parse(Faraday.get(url).body)['items']
  customers.each { |c| puts JSON.pretty_generate c }
  puts "#{customers.count} records served & consumed at #{Time.now.asctime} ..."
  puts "\n\n"
  sleep interval
end
