require "yaml"
preamble, yaml, _ = File.read("main.yaml").split("\n\n")
puts preamble
YAML.load(yaml).each do |region, resources|
  puts "## #{region}"
  puts "| название | уровень<br>свидомости | пруфы | заблокирован<br>в РФ |"
  puts "| -------- | :-------------------: | ----- | :------------------: |"
  puts( resources.map do |req, opt|
    link, banned, alexa, name = req.split(" ", 4)
    _ = opt.fetch(:links, []).map{ |_| _.split(" ", 4).tap{ |_| _[3] = _[3] } }.transpose
    _ = [[0], [], [], []] if _.empty?
    domain = link[/[^\/]+\z/]
    ["#{name ? "[#{name}](#{link}) #{domain.sub /./, '\0<area>'}" : "[#{domain}](#{link})"}#{
      " (#{opt[:comment]})" if opt.key? :comment
    }#{
      "<br>#{opt[:chefs].gsub ", ", "<br>"}" if opt.key? :chefs
    } | #{_[0].max} | #{
      _[1].zip(_[2]).sort_by(&:last).map.with_index{ |(__,*), i| "[[#{i + 1}]](#{__})" }.join(", ")
    }#{
      _[3].compact.uniq.sort.map{ |_| "<br>#{_}" }.join
    } | #{banned}", alexa.to_i]
  end.sort_by(&:last).map(&:first) )
  puts ""
end
