require_relative '../genablog.rb'
require 'set'
# Public: Main class for reading a Genablog and writing a web page.
#
# Examples
#
#   genablog = Genablog::Blog.new("/path/to/genablog")
#   genablog.read_all!
#   genablog.write_all
#   # => A compiled Genablog webpage in the given Genablog's out directory
class Genablog::Blog

  # Constants
  # Directory in the Genablog that contains input files
  @@GENABLOG_IN_ROOT_DIRECTORY = "in/"
  # Location of the Genablog's configuration file
  @@GENABLOG_CONFIG_FILE = "#{@@GENABLOG_IN_ROOT_DIRECTORY}genablog.cfg"
  # Location of the directory in the Genablog that contains static webpages
  @@GENABLOG_IN_STATIC_DIRECTORY = "#{@@GENABLOG_IN_ROOT_DIRECTORY}static/"
  # Location of the directory in the Genablog that contains the blog entries
  @@GENABLOG_IN_BLOG_DIRECTORY = "#{@@GENABLOG_IN_ROOT_DIRECTORY}blog/"
  # Location of the directory in the Genablog that contains global assets
  @@GENABLOG_IN_GLOB_ASSET_DIRECTORY = "#{@@GENABLOG_IN_ROOT_DIRECTORY}assets/"
  # Location of the main html file in a blog entry
  @@GENABLOG_IN_BLOG_BODY_FILE = "body.html"
  # Location of a directory containing a blog entry's assets.
  @@GENABLOG_IN_BLOG_ASSET_DIRECTORY = "assets/"
  # Locaion of the directory in a Genablog to write outputed websites
  @@GENABLOG_OUT_ROOT_DIRECTORY = "out/"
  # Directory in an outputed Genablog webpage to write years pages
  @@GENABLOG_OUT_YEARS_DIRECTORY = "years/"
  # Directory in an outputed Genablog webpage to write blog pages
  @@GENABLOG_OUT_BLOG_DIRECTORY = "blog/"
  # Directory in an outputed Genablog webpage to write tags pages
  @@GENABLOG_OUT_TAGS_DIRECTORY = "tags/"
  # Directory in an outputed Genablog webpage to store blog assets
  @@GENABLOG_OUT_ASSETS_DIRECTORY = "assets/"
  # Directory in an outputed Genablog to store global global assets
  @@GENABLOG_OUT_GLOB_ASSETS_DIRECTORY = @@GENABLOG_OUT_ASSETS_DIRECTORY +
                                         "_global/"
  # Name of a blog when none is given
  @@DEFAULT_BLOG_TITLE = "My Blog"
  # Author of a blog when none is given 
  @@DEFAULT_AUTHOR = "Anonymous"

  # Public: Initialize a Genablog
  #
  # blog_location - String containing location of the Genablog
  def initialize(blog_location)
    blog_location = blog_location.strip()
    blog_location = blog_location + "/" unless blog_location.end_with?("/")
    unless File.directory?(blog_location)
      puts "#{blog_location} is not a valid directory"
      exit 1
    end
    @blog_location = blog_location

    # Parse genablog.cfg
    @blog_title = @@DEFAULT_BLOG_TITLE
    @blog_author = @@DEFAULT_AUTHOR
    @blog_navlist = Array.new
    blog_config_file_location = @blog_location + @@GENABLOG_CONFIG_FILE
    unless File.file?(blog_config_file_location)
      puts "Blog configuration file #{blog_config_file_location} not found."
      exit 1
    end
    File.open(blog_config_file_location).readlines.each do |line|
      line_split = line.strip.split(":")
      if line_split.length > 1
        case line_split[0].strip.downcase
        when "title" then @blog_title = line_split[1]
        when "author" then @blog_author = line_split[1]
        when "navlist" then @blog_navlist = line_split[1].split(",")
        end
      end
    end

    # Initialize web page arrays
    @static_webpages = Array.new
    @blog_webpages = Array.new
    @tags = Array.new

    # Determine output directory
    today = Time.new.strftime('%Y%m%d%H%M%S')
    @output_root_directory = "#{@blog_location}#{@@GENABLOG_OUT_ROOT_DIRECTORY}"
    @output_run_directory = "#{@output_root_directory}#{today}/"

    # Common file locations
    in_root = "#{@blog_location}#{@@GENABLOG_IN_ROOT_DIRECTORY}"
    @blog_header_location = "#{in_root}header.html"
    @blog_footer_location = "#{in_root}footer.html"
  end

  # Public: Prints the read contents of the genablog
  #
  # Returns nothing
  def print
    puts "Blog Location: #{@blog_location}"
    puts "Title: #{@blog_title}"
    puts "Author: #{@blog_author}"
    puts "Navlist: #{@blog_navlist}"
    puts "Static Pages:"
    puts "----------"
    @static_webpages.each { |static_page| static_page.print }
    puts "Blog Pages:"
    puts "----------"
    @blog_webpages.each { |blog_page| blog_page.print }
    puts "Tags:"
    puts "----------"
    @tags.each { |tag| tag.print}
  end

  # Public: Reads all Genablog input files.  This method populates the
  # @blog_webpages, @static_webpages, and @tags arrays.  After this method is
  # run, the Blog object will contain all information necesary to output a web
  # page.
  #
  # Returns nothing
  def read_all!
    read_blog!
    read_static!
    index_tags!
  end

  # Public: Reads all blog entries in the Genablog's input files.  This method
  # populates the @blog_webpages array
  #
  # Returns nothing
  def read_blog!
    blog_in_blog_location = @blog_location + @@GENABLOG_IN_BLOG_DIRECTORY
    if File.directory?(blog_in_blog_location)
      Dir.foreach(blog_in_blog_location) do |blog_entry|
        next if blog_entry == "."
        next if blog_entry == ".."
        blog_entry_location = blog_in_blog_location + blog_entry
        if File.directory?(blog_entry_location)
          blog_webpage = Genablog::BlogPage.new( blog_entry,
                                                 @blog_location,
                                                 @blog_navlist,
                                                 @blog_author)
          @blog_webpages.push blog_webpage
        end
      end
    end
    @blog_webpages.sort_by! {|page| page.get_date}
  end

  # Public: Reads all static web pages in the Genablog's input files.  This
  # method populates the @static_webpages array
  #
  # Returns nothing
  def read_static!
    blog_in_static_location = @blog_location + @@GENABLOG_IN_STATIC_DIRECTORY
    if File.directory?(blog_in_static_location)
      Dir.foreach(blog_in_static_location) do |static_file_name|
        static_file_location = blog_in_static_location + static_file_name
        static_file_title = static_file_name.strip.split(".")[0]
        if File.file?(static_file_location)
          static_webpage = Genablog::WebPage.new( static_file_title,
                                                  @blog_location,
                                                  @blog_navlist )
          @static_webpages.push static_webpage
        end
      end
    end
  end

  # Public: Catalogs the blog entries in @blog_webpages to create Tag objects.
  # Thes tags are stored in the @tags array
  #
  # Returns nothing
  def index_tags!
    added_tags = Array.new
    @blog_webpages.each do |webpage_i|
      webpage_i.get_tags.each do |webpage_tag|
        if !added_tags.include?(webpage_tag)
          tag_to_add = Genablog::Tag.new(webpage_tag)
          tag_to_add.add_target webpage_i
          @tags.push tag_to_add
          added_tags.push webpage_tag
        else
          @tags.each do |blog_tag|
            if blog_tag.get_label == webpage_tag
              blog_tag.add_target webpage_i
              break
            end
          end
        end
      end
    end
    @tags.sort_by! {|tag| tag.get_label}
  end

  # Public: Creates a complete webpage in the Genablog's output directory
  #
  # Returns nothing
  def write_all
    create_output_directories
    write_root_pages
    write_years_pages
    write_blog_pages
    write_tags_pages
    copy_assets
  end

  # Public: Writes only the skeleton directories of a Genablog in the
  # Gebablogs's output directory
  #
  # Returns nothing
  def create_output_directories
    unless File.exists?(@output_root_directory)
      Dir.mkdir(@output_root_directory, 0755)
    end

    if File.directory?(@output_run_directory)
      puts "Output directory #{@output_root_directory} already exists."
    else
      Dir.mkdir(@output_run_directory, 0755)
      Dir.mkdir("#{@output_run_directory}years", 0755)
      Dir.mkdir("#{@output_run_directory}blog", 0755)
      Dir.mkdir("#{@output_run_directory}tags", 0755)
      Dir.mkdir("#{@output_run_directory}assets", 0755)
    end
  end

  # Public: Writes only the index page, tags page, and static pages in the
  # Genablog's output directory.
  #
  # Returns nothing
  def write_root_pages
    # Write index.html
    index_out = File.open("#{@output_run_directory}index.html", "w")
    write_header(index_out,0)
    index_out.write '<div class=\'gb_link_area\'>'
    month_i = 13
    years = Set.new
    first_header = true
    @blog_webpages.reverse_each do |webpage|
      if webpage.get_date.year == Date.today.year
        if month_i > webpage.get_date.month
          month_i = webpage.get_date.month
          if first_header
            first_header = false
          else
            index_out.write "</div>\n"
          end
          month_header = "<div class=gb_link_grouping>" +
                         '<span class=\'gb_header\'>' +
                         webpage.get_date.strftime('%B') +
                         "</span><br/>\n"
          index_out.write month_header
        end
        link = '<a class=\'gb_link\' href=\'' +
               @@GENABLOG_OUT_BLOG_DIRECTORY +
               webpage.get_page_name +
               '\'>' +
               webpage.get_title +
               "</a><br/>\n"

        index_out.write link
      else
        years.add(webpage.get_date.year)
      end
    end
    index_out.write "</div>\n<div class=\'gb_link_grouping\'>\n" +
                    "<span class=\'gb_header\'>Archive</span><br/>\n"
    years.each do |year|
      link = '<a class=\'gb_link\' href=\'' +
             @@GENABLOG_OUT_YEARS_DIRECTORY +
             year.to_s +
             ".html\'>" +
             year.to_s +
             "</a><br/>\n"

      index_out.write link
    end
    index_out.write "</div>\n</div>\n<br/>\n"
    write_footer(index_out, 0)
    index_out.close

    # Write tags.html
    tags_out = File.open("#{@output_run_directory}tags.html", "w")
    write_header(tags_out, 0)
    tags_out.write "<div class=\'gb_link_area\'>\n"
    tags_out.write "<div class=\'gb_link_grouping\'>"
    tags_i = '?'
    @tags.each do |tag|
      if tag.get_label.length > 0 && ( tags_i <=> tag.get_label[0] ) == -1
        tags_i = tag.get_label[0]
        tag_header = "</div>\n<div class=\'gb_link_grouping\'>" +
                     '<span class=\'gb_header\'>' +
                     tags_i.upcase +
                     "</span><br/>\n"
        tags_out.write tag_header
      end
      link = '<a class=\'gb_link\' href=\'' +
             @@GENABLOG_OUT_TAGS_DIRECTORY +
             tag.get_page_name +
             '\'>' +
             tag.get_label +
             "</a><br/>\n"

      tags_out.write link
    end
    tags_out.write "</div>\n</div>\n<br/>"
    write_footer(tags_out, 0)
    tags_out.close

    # Write static pages
    @static_webpages.each do |webpage|
      webpage_out_location = "#{@output_run_directory}#{webpage.get_page_name}"
      webpage_in_location = @blog_location +
                            @@GENABLOG_IN_STATIC_DIRECTORY +
                            webpage.get_page_name
      webpage_out = File.open(webpage_out_location, "w")
      write_header(webpage_out, 0)
      File.open(webpage_in_location).readlines.each do |line|
        webpage_out.write line
      end
      write_footer(webpage_out, 0)
      webpage_out.close
    end
  end

  # Public: Writes only the years (archive) pages in the Genablog's output
  # directory.
  #
  # Returns nothing
  def write_years_pages
    year_target = Date.today.year
    year_out_file = @output_run_directory +
                    @@GENABLOG_OUT_YEARS_DIRECTORY +
                    year_target.to_s +
                    ".html"
    year_out = File.open(year_out_file, "w")
    write_header year_out
    @blog_webpages.reverse_each do |webpage|
      year_i = webpage.get_date.year
      if year_i < year_target
        year_out.write "</div>\n"
        write_footer year_out
        year_out.close
        year_target = year_i
        year_out_file = @output_run_directory +
                        @@GENABLOG_OUT_YEARS_DIRECTORY +
                        year_target.to_s +
                        ".html"
        year_out = File.open(year_out_file, "w")
        write_header year_out
        year_header = "<div class=\'gb_link_grouping\'>" +
                      '<span class=\'gb_header\'>' +
                      year_i.to_s +
                      "</span><br/>\n"
        year_out.write year_header
      end
      link = '<a class=\'gb_link\' href=\'../' +
             @@GENABLOG_OUT_BLOG_DIRECTORY +
             webpage.get_page_name +
             '\'>' +
             webpage.get_title +
             "</a><br/>\n"
      year_out.write link
    end
    year_out_file = @output_run_directory +
                    @@GENABLOG_OUT_YEARS_DIRECTORY +
                    year_target.to_s +
                    ".html"
    year_out = File.open(year_out_file, "a")
    write_header year_out
    year_out.close
  end

  # Public: Writes only the blog entry pages in the Genablog's output directory.
  # HTML referencing the blog entry's assets directory will be transformed to
  # reference the entry's asset directory in the outputed web page.
  #
  # Returns nothing

  def write_blog_pages
    @blog_webpages.each do |webpage|
      webpage_out_location = @output_run_directory +
                             @@GENABLOG_OUT_BLOG_DIRECTORY +
                             webpage.get_page_name
      webpage_in_location = webpage.get_location +
                            @@GENABLOG_IN_BLOG_BODY_FILE
      webpage_out = File.open(webpage_out_location, "w")
      write_header(webpage_out, 1)
      blog_header = "<span class=\'gb_blog_title\'>" +
                    webpage.get_title +
                    "</span><br/>\n<span class=\'gb_blog_author\'>" +
                    webpage.get_author +
                    "</span><br/>\n<span class=\'gb_blog_date\'>" +
                    webpage.get_date.to_s +
                    "</span><br/>\n"
      webpage_out.write(blog_header)
      File.open(webpage_in_location).readlines.each do |line|
        line.gsub!('assets/', "../assets/#{webpage.get_title}/")
        webpage_out.write line
      end
      write_footer webpage_out
      webpage_out.close
    end
  end

  # Public: Writes only the tag pages in the Genablog's output directory.
  #
  # Returns nothing
  def write_tags_pages
    @tags.each do |tag|
      tagpage_out_location = @output_run_directory +
                             @@GENABLOG_OUT_TAGS_DIRECTORY +
                             tag.get_page_name
      tagpage_out = File.open(tagpage_out_location, "w")
      write_header(tagpage_out, 1)
      tag_header =  "<div class=\'gb_link_grouping\'>\n" +
                    '<span class=\'gb_header\'>' +
                    tag.get_label +
                    "</span><br/>\n"
      tagpage_out.write tag_header
      tag.get_targets.each do |target|
        link = '<a class=\'gb_link\' href=\'../' +
               @@GENABLOG_OUT_BLOG_DIRECTORY +
               target.get_page_name +
               '\'>' +
               target.get_title +
               "</a><br/>\n"
        tagpage_out.write link
      end
      tagpage_out.write "</div>\n"
      write_footer tagpage_out
      tagpage_out.close
    end
  end

  # Public: Copies assets from the global asset directory and each blog entry's
  # asset directory to their corresponding directory in the outputed webpage.
  #
  # Returns nothing
  def copy_assets
    global_target_dir = @output_run_directory +
                        @@GENABLOG_OUT_GLOB_ASSETS_DIRECTORY
    global_source_dir = "#{@blog_location}#{@@GENABLOG_IN_GLOB_ASSET_DIRECTORY}"
    copy_asset_dir(global_source_dir, global_target_dir)
    @blog_webpages.each do |webpage|
      blog_source_dir = webpage.get_location +
                        @@GENABLOG_IN_BLOG_ASSET_DIRECTORY
      blog_target_dir = @output_run_directory +
                        @@GENABLOG_OUT_ASSETS_DIRECTORY +
                        webpage.get_title
      copy_asset_dir(blog_source_dir, blog_target_dir)
    end
  end

  private
  # Private: Writes the standard Genablog header to the given file
  #
  # target - Open File object to write to
  # depth  - How deep the target file is located in the outputed web page's
  #          directory tree. (out/index.html would be depth 0,
  #          out/blog/Entry.html would be depth 1, etc.)
  #
  # Returns nothing
  def write_header(target, depth=1)
    depth_dirs = ""
    depth.times { depth_dirs = "#{depth_dirs}../" }
    File.open(@blog_header_location).readlines.each do |line|
      line.gsub!('assets/_global', "#{depth_dirs}assets/_global")
      target.write line
    end
    navbar = "<div class=\'gb_navbar\'>- - - <a class=\'gb_navbar_link\' href=\'" +
             depth_dirs +
             "index.html\'>Home</a> - "
    if @tags.size > 0
      navbar = navbar +
              '<a class=\'gb_navbar_link\' href=\'' +
              depth_dirs +
              "tags.html\'>Tags</a> - "
    end
    @static_webpages.each do |page|
      navbar = navbar +
               '<a class=\'gb_navbar_link\' href=\'' +
               depth_dirs +
               page.get_page_name +
               '\'>' +
               page.get_title +
               '</a> - '
    end
    navbar = "#{navbar}- -<br/>\n</div>"
    target.write navbar
  end

  # Private: Writes the standard Genablog footer to the given file
  #
  # target - Open File object to write to
  # depth  - How deep the target file is located in the outputed web page's
  #          directory tree. (out/index.html would be depth 0,
  #          out/blog/Entry.html would be depth 1, etc.)
  #
  # Returns nothing
  def write_footer (target, depth=1)
    depth_dirs = ""
    depth.times { depth_dirs = "#{depth_dirs}../" }
    File.open(@blog_footer_location).readlines.each do |line|
      line.gsub!('assets/_global', "#{depth_dirs}assets/_global")
      target.write line
    end
  end

  # Private: Utility method for recursively copying assets.
  #
  # source_dir - Path of directory to be copied
  # target_dir - Path to copy to
  #
  # Returns nothing
  def copy_asset_dir (source_dir, target_dir)
    Dir.mkdir(target_dir, 0755) unless File.directory?(target_dir)
    if File.directory?(source_dir)
      Dir.foreach(source_dir) do |asset|
        if asset[0] != '.'
          asset_source_location = "#{source_dir}/#{asset}"
          asset_target_location = "#{target_dir}/#{asset}"
          if File.directory? asset_source_location
            copy_asset_dir(asset_source_location, asset_target_location)
          elsif File.file? asset_source_location
            target_file = File.open(asset_target_location, "w")
            read_file = File.open(asset_source_location, "r")
            while buffer = read_file.read(2048)
              target_file.write buffer
            end
            read_file.close
            target_file.close
          end
        end
      end
    end
  end

end
