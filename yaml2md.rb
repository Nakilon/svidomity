require "yaml"
puts "# Специализированный навигатор по украинским СМИ"

# 1 - когда просто недостоверная информация без злого умысла
# 2 - намеренное разжигаение, фейки и особая лексика

YAML.load(File.read "websites.yaml").each do |region, resources|
  puts "\n## #{region}"
  puts "| название | уровень<br>свидомости | посты и<br>их авторы | заблокирован<br>в РФ |"
  puts "| -------- | :-------------------: | -------------------- | :------------------: |"
  puts( resources.map do |req, opt|
    link, alexa, name = req.split(" ", 3)
    links = opt.fetch(:links, []).map{ |_| _.split(" ", 4).tap{ |_| _[3] = _[3] } }.transpose
    links = [[0], [], [], []] if links.empty?
    domain = link[/[^\/]+\z/]
    ["#{name ? "[#{name}](#{link}) #{domain.sub /./, '\0<area>'}" : "[#{domain}](#{link})"}#{  # IIRC <area> is a hack against autolinking on Github
      " (#{opt[:comment]})" if opt.key? :comment
    }#{
      "<br>#{opt[:chiefs].gsub ", ", "<br>"}" if opt.key? :chiefs
    } | #{links[0].max} | #{
      links[1].zip(links[2]).sort_by(&:last).map.with_index{ |(__,*), i| "[[#{i + 1}]](#{__})" }.join(", ")
    }#{
      links[3].compact.uniq.sort.map{ |_| "<br>#{_}" }.join
    } | #{opt[:banned] ? "да" : "нет"}", alexa.to_i]
  end.sort_by(&:last).map(&:first) )
end

YAML.load(File.read "vk.yaml").each do |region, resources|
  puts "\n## #{region}"
  puts "| название | уровень<br>свидомости | посты и<br>их авторы |"
  puts "| -------- | :-------------------: | -------------------- |"
  puts( resources.map do |req, opt|
    link, subs, name = req.split(" ", 3)
    links = opt.fetch(:links, []).map{ |_| _.split(" ", 4).tap{ |_| _[3] = _[3] } }.transpose
    links = [[0], [], [], []] if links.empty?
    ["[#{name}](#{"https://vk.com/#{link}"}) #{link}#{
      " (#{opt[:comment]})" if opt.key? :comment
    }#{
      "<br>#{opt[:chiefs].gsub ", ", "<br>"}" if opt.key? :chiefs
    } | #{links[0].max} | #{
      links[1].zip(links[2]).sort_by(&:last).map.with_index{ |(__,*), i| "[[#{i + 1}]](#{__})" }.join(", ")
    }#{
      links[3].compact.uniq.sort.map{ |_| "<br>#{_}" }.join
    }", -subs.to_i.to_i]
  end.sort_by(&:last).map(&:first) )
end
