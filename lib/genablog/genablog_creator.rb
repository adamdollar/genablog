# Public: Utility class for writing skeleton input files for Genablog
class Genablog::GenablogCreator

  # Content of default header.html
  @@DEFAULT_HEADER_HTML =<<EOF
<html>
<link rel="stylesheet" type="text/css" href="assets/_global/blog.css">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
</head>
<body>
<h1>Welcome to my blog</h1>
EOF

  # Content of default footer.html
  @@DEFAULT_FOOTER_HTML =<<EOF
</body>
<footer>
</footer>
EOF

  # Content of default blog css file
  @@DEFAULT_BLOG_CSS =<<EOF
.gb_navbar {

}

.gb_navbar_link {

}

.gb_link_area {

}

.gb_link_grouping {

}

.gb_link {

}

.gb_header {

}

.gb_blog_title {

}

.gb_blog_author {

}

.gb_blog_date {

}
EOF

  # Public: Create a skeleton file for a new genablog
  #
  # target_location - Location in which to create a new genablog
  #
  # Return nothing
  def create_new_blog(target_location)
    target_location = target_location.strip()
    unless target_location.end_with?("/")
      target_location = target_location + "/"
    end
    if File.exist?(target_location)
      puts "#{target_location} already exists."
      exit 1
    end
    # Create directories
    Dir.mkdir(target_location, 0755)
    Dir.mkdir("#{target_location}in", 0755)
    Dir.mkdir("#{target_location}in/assets", 0755)
    Dir.mkdir("#{target_location}in/blog", 0755)
    Dir.mkdir("#{target_location}in/static", 0755)
    Dir.mkdir("#{target_location}out", 0755)
    # Create Header
    File.open("#{target_location}in/header.html", "w") do |header_html|
      header_html.write(@@DEFAULT_HEADER_HTML)
    end
    # Create Footer
    File.open("#{target_location}in/footer.html", "w") do |footer_html|
      footer_html.write(@@DEFAULT_FOOTER_HTML)
    end
    # Create blog config file
    config_file = File.open("#{target_location}in/genablog.cfg", "w")
    print "Blog title: "
    blog_title = STDIN.gets
    config_file.write "title:#{blog_title}"
    print "Default blog author: "
    blog_author = STDIN.gets
    config_file.write "author:#{blog_author}"
    config_file.close
    # Create blog css
    File.open("#{target_location}in/assets/blog.css", "w") do |footer_html|
      footer_html.write(@@DEFAULT_BLOG_CSS)
    end
  end

  # Public: Create a skeleton file for a new genablog entry
  #
  # target_blog - Location of blog to create new entry
  # title       - Title of new blog entry
  # tags        - Tags of new blog entry as an array of strings
  #
  # Return nothing
  def create_new_blog_entry(target_blog, title, tags)
    # Check if valid blog
    valid_blog = true
    valid_blog = false unless File.directory? target_blog
    valid_blog = false unless File.directory? "#{target_blog}/in"
    valid_blog = false unless File.directory? "#{target_blog}/in/blog"
    valid_blog = false unless File.exist? "#{target_blog}/in/genablog.cfg"
    if valid_blog
      target_entry = "#{target_blog}/in/blog/#{title.gsub(/\s/,'_')}"
      if File.directory? target_entry
        puts "#{title} already exists in #{target_blog}"
      else
        Dir.mkdir(target_entry, 0755)
        Dir.mkdir("#{target_entry}/assets", 0755)
        File.open("#{target_entry}/body.html", "w") {}
        meta = File.open("#{target_entry}/meta.cfg", "w")
        meta.write "title:#{title}\n"
        meta.write "date:#{Date.today.strftime("%Y%m%d")}\n"
        meta.write "tags:#{tags.join(',')}\n" unless tags.empty?
        meta.close()
      end
    else
      puts "Invalid genablog: #{target_blog}"
    end
  end
end
