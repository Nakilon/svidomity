require "commonmarker"
require "oga"
require "tablestructured"
puts <<~HEREDOC
  <!DOCTYPE html>
  <html>
    <head>
      <!--<link rel="stylesheet" type="text/css" href="./light-92c7d381038e.css"/>-->
      <!--<link rel="stylesheet" type="text/css" href="./primer-856885a5a549.css"/>-->
      <style>#{File.read "markdown.css"}</style>
    </head>
    <body class="markdown-body Box-body">
      #{
        Oga.parse_html(CommonMarker.render_html ARGF.read, %i{ DEFAULT UNSAFE }, %i{ table }).tap do |html|
          html.css("table").each do |_|
            TableStructured.new(_).each do |_|
              _.values.first.set "style", (
                case _.уровеньсвидомости.text
                when "2" ; "background-color: #ffeeee"
                when "1" ; "background-color: #ffffee"
                when "0" ; "background-color: #eeffee"
                when "-1" ; "background-color: #ffffee"
                else ; fail "invalid уровень свидомости #{_.уровеньсвидомости.text.inspect}"
                end
              )
            end
          end
        end
      }
    </body>
  </html>
HEREDOC
