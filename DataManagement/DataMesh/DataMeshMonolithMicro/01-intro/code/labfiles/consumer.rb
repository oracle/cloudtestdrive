require 'faraday'
require 'json'
url = ARGV[0]
interval = ARGV.fetch(1,10).to_i
output_file = File.new('./demographics.json','a+')
record_count = output_file.readlines.count
loop do
  customers = JSON.parse(Faraday.get(url).body)['items']
  if customers.count > record_count
    new_customers = customers.last(customers.count - record_count)
    puts "#{new_customers.count} new customer records found:"
    new_customers.each do |c|
      output_file.puts JSON.generate c
      puts JSON.pretty_generate c
    end
    output_file.flush
    record_count += new_customers.count
  end
  puts "#{record_count} records consumed at #{Time.now.asctime} ..."
  puts "\n\n"
  sleep interval
end