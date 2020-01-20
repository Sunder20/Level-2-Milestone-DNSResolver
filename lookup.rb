def get_command_line_argument
  # ARGV is an array that Ruby defines for us,
  # which contains all the arguments we passed to it
  # when invoking the script from the command line.
  # https://docs.ruby-lang.org/en/2.4.0/ARGF.html
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

# `domain` contains the domain name we have to look up.
domain = get_command_line_argument

# File.readlines reads a file and returns an
# array of string, where each element is a line
# https://www.rubydoc.info/stdlib/core/IO:readlines
dns_raw = File.readlines("zone")

def parse_dns(dns_raw)
  dns_records = {}
  dns_raw.each do |line|
    unless line[0] == "\n" or line[0] == "#"
      a = line.split ","
      if a[0].strip == "A"
        dns_records[a[1].strip] = { :rec_type => "A", :ip => a[2].chomp.strip }
      else
        dns_records[a[1].strip] = { :rec_type => "CNAME", :alias => a[2].chomp.strip }
      end
    end
  end
  return dns_records
end

def resolve(dns_records, lookup_chain, domain)
  lookup = dns_records[domain]

  if lookup == nil
    lookup_chain = ["Warning : The domain '#{domain}' is not found"]
  elsif lookup[:rec_type] == "A"
    lookup_chain.push lookup[:ip]
  else
    lookup_chain.push lookup[:alias]
    lookup_chain = resolve(dns_records, lookup_chain, lookup[:alias]) 
  end

  return lookup_chain
end

# To complete the assignment, implement `parse_dns` and `resolve`.
# Remember to implement them above this line since in Ruby
# you can invoke a function only after it is defined.
dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
