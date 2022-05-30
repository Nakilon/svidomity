require "commonmarker"
puts <<~HEREDOC
  <!DOCTYPE html>
  <html>
    <head>
      <!--<link rel="stylesheet" type="text/css" href="./light-92c7d381038e.css"/>-->
      <!--<link rel="stylesheet" type="text/css" href="./primer-856885a5a549.css"/>-->
      <style>#{File.read "markdown.css"}</style>
    </head>
    <body class="markdown-body Box-body">
      #{CommonMarker.render_html ARGF.read, %i{ DEFAULT UNSAFE }, %i{ table }}
    </body>
  </html>
HEREDOC
