require 'json'

ARGF.each_line do |line|
  data = JSON.parse(line)

  parsed = data['message']
    .scan(/(\w+)=(\w+|"([^"]*)")+/)
    .map { |k,v,v2| [k, (v2&.gsub("\\\"", "\"")&.gsub("\\\\", "\\")) || v] }
    .map { |k,v| [k, (Integer(v) rescue v)] }
    .to_h

  data['message_parsed'] = parsed
  data['site'] = ENV['SITE']

  if m = /(ec2|gce|wjb)/.match(data['source_name'])
    data['infra'] = m[0] == 'wjb' ? 'macstadium' : m[0]
  end

  puts data.to_json
end
