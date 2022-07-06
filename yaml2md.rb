require "yaml"
puts "# Специализированный навигатор по украинским СМИ"
puts "\nУровень свидомости определяется следующим образом:"
puts "* 2 (красный) -- намеренное разжигаение, фейки и особая лексика"
puts "* 1 (желтый) -- когда просто недостоверная информация без злого умысла"

process_yaml_file = lambda do |filename, header, &block|
  YAML.load(File.read "#{filename}.yaml").each do |region, resources|
    puts "\n## #{region}", header
    puts resources.map(&block).sort_by(&:last).map(&:first)
  end
end

process_yaml_file.call("websites", <<~HEREDOC) do |req, opt|
  | название | уровень<br>свидомости | посты и<br>их авторы | заблокирован<br>в РФ |
  | -------- | :-------------------: | -------------------- | :------------------: |
HEREDOC
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
end

process_yaml_file.call("vk", <<~HEREDOC) do |req, opt|
  | название | уровень<br>свидомости | посты |
  | -------- | :-------------------: | ----- |
HEREDOC
    link, subs, name = req.split(" ", 3)
    links = opt.fetch(:links, []).map(&:split).transpose
    links = [[0], [], []] if links.empty?
    ["[#{name}](#{"https://vk.com/#{link}"}) #{link}#{
      " (#{opt[:comment]})" if opt.key? :comment
    }#{
      "<br>#{opt[:chiefs].gsub ", ", "<br>"}" if opt.key? :chiefs
    } | #{links[0].max} | #{
      links[1].zip(links[2]).sort_by(&:last).map.with_index{ |(__,*), i| "[[#{i + 1}]](#{__})" }.join(", ")
    }", -subs.to_i]
end

process_yaml_file.call("tg", <<~HEREDOC) do |req, opt|
  | название | уровень<br>свидомости | посты |
  | -------- | :-------------------: | ----- |
HEREDOC
    link, subs, name = req.split(" ", 3)
    links = opt.fetch(:links, []).map(&:split).transpose
    links = [[0], [], []] if links.empty?
    ["[#{name}](#{"https://t.me/#{link}"}) #{link}#{
      " (#{opt[:comment]})" if opt.key? :comment
    }#{
      "<br>#{opt[:chiefs].gsub ", ", "<br>"}" if opt.key? :chiefs
    } | #{links[0].max} | #{
      links[1].zip(links[2]).sort_by(&:last).map.with_index{ |(__,*), i| "[[#{i + 1}]](#{__})" }.join(", ")
    }", -subs.to_i]
end
