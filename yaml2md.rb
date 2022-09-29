require "yaml"
puts "# Специализированный навигатор по украинским СМИ"
puts "\nУровень свидомости определяется следующим образом:"
puts "* 2 (красный) -- намеренное разжигаение, фейки и особая лексика"
puts "* 1 (желтый) -- когда просто недостоверная информация без злого умысла"
puts "* 0 -- ресурс годен к употреблению"
puts "* -1 -- склонность к антиукраинским фейкам и особой лексике (\"роговщина\")"

process_yaml_file = lambda do |filename, header, &block|
  begin
    YAML.load(File.read "#{filename}.yaml")
  rescue Psych::SyntaxError
    raise $!.exception "#{$!} (#{filename})"
  end.each do |region, resources|
    puts "\n## #{region}", header
    puts resources.map(&block).sort_by{ |_,| [_.zero? ? 1 : 0, _] }.map(&:last)
  end
end

process_yaml_file.call("websites", <<~HEREDOC) do |req, opt|
  | название | уровень<br>свидомости | посты и<br>их авторы | заблокирован<br>в РФ |
  | -------- | :-------------------: | -------------------- | :------------------: |
HEREDOC
    link, rank, name = req.split(" ", 3)
    links = opt.fetch(:links, []).map{ |_| _.split(" ", 4).tap{ |_| _[3] = _[3] } }.transpose
    links = [[0], [], [], []] if links.empty?
    domain = link[/[^\/]+\z/]
  [
    rank.to_i,
    "#{name ? "[#{name}](#{link}) #{domain.sub /./, '\0<area>'}" : "[#{domain}](#{link})"}#{  # IIRC <area> is a hack against autolinking on Github
      " (#{opt[:comment]})" if opt.key? :comment
    }#{
      "<br>#{opt[:chiefs].gsub ", ", "<br>"}" if opt.key? :chiefs
    } | #{links[0].max} | #{
      links[1].zip(links[2]).sort_by(&:last).map.with_index{ |(__,*), i| "[[#{i + 1}]](#{__})" }.join(", ")
    }#{
      links[3].compact.uniq.sort.map{ |_| "<br>#{_}" }.join
    } | #{opt[:banned] ? "да" : "нет"}"
  ]
end

process_yaml_file.call("vk", <<~HEREDOC) do |req, opt|
  | название | уровень<br>свидомости | посты | заблокирован<br>в РФ |
  | -------- | :-------------------: | ----- | :------------------: |
HEREDOC
    link, subs, name = req.split(" ", 3)
    links = opt.fetch(:links, []).map(&:split).transpose
    links = [[0], [], []] if links.empty?
  [
    -subs.to_i,
    "[#{name}](#{"https://vk.com/#{link}"}) #{link}#{
      " (#{opt[:comment]})" if opt.key? :comment
    }#{
      "<br>#{opt[:chiefs].gsub ", ", "<br>"}" if opt.key? :chiefs
    } | #{links[0].max} | #{
      links[1].zip(links[2]).sort_by(&:last).map.with_index{ |(__,*), i| "[[#{i + 1}]](#{__})" }.join(", ")
    } | #{opt[:banned] ? "да" : "нет"}"
  ]
end

process_yaml_file.call("tg", <<~HEREDOC) do |req, opt|
  | название | уровень<br>свидомости | посты |
  | -------- | :-------------------: | ----- |
HEREDOC
    link, subs, name = req.split(" ", 3)
    links = opt.fetch(:links, []).map(&:split).transpose
    links = [[0], [], []] if links.empty?
  [
    -subs.to_i,
    "[#{name}](#{"https://t.me/#{link}"}) #{link}#{
      " (#{opt[:comment]})" if opt.key? :comment
    }#{
      "<br>#{opt[:chiefs].gsub ", ", "<br>"}" if opt.key? :chiefs
    } | #{links[0].max} | #{
      links[1].zip(links[2]).sort_by(&:last).map.with_index{ |(__,*), i| "[[#{i + 1}]](#{__})" }.join(", ")
    }"
  ]
end
