require "yaml"
puts ARGF.gets
YAML.load(ARGF.read).each do |region, resources|
  puts "\n## #{region}"
  puts "| название | уровень<br>свидомости | статьи и их авторы | заблокирован<br>в РФ |"
  puts "| -------- | :-------------------: | ------------------ | :------------------: |"
  puts( resources.map do |req, opt|
    link, alexa, name = req.split(" ", 3)
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
    } | #{opt[:banned] ? "да" : "нет"}", alexa.to_i]
  end.sort_by(&:last).map(&:first) )
end
