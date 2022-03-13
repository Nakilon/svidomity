require "yaml"
preamble, yaml, _ = File.read("main.yaml").split("\n\n")
puts preamble
YAML.load(yaml).each do |region, resources|
  puts "## #{region}"
  puts "| название | уровень<br>свидомости | пруфы |"
  puts "| -------- | --------------------- | ----- |"
  puts( resources.map do |req, opt|
    domain, banned, alexa, name = req.split(" ", 4)
    _ = opt.fetch(:links, []).map{ |_| _.split(" ", 4).tap{ |_| _[3] = _[3] } }.transpose
    _ = [[0], [], [], []] if _.empty?
    "| [#{name}](#{domain})#{
      "<br>#{opt[:comment]}" if opt.key? :comment
    }#{
      "<br>#{opt[:chefs].gsub ", ", "<br>"}" if opt.key? :chefs
    } | #{_[0].max} | #{
      _[1].map.with_index{ |_, i| "[[#{i + 1}]](#{_})" }.join(", ")
    } |"
  end.sort )
  puts ""
end
