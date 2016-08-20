require_relative '../genablog.rb'
require 'time'
# Public: Contains the metadate of a Genablog blog entry
class Genablog::BlogPage < Genablog::WebPage
  # Constants
  # Directory in a Genablog that contains blog entries
  @@BLOG_ENTRY_DIRECTORY_LOCATION = "in/blog/"
  # File in a blog entry that contains metadata
  @@BLOG_ENTRY_CONFIG_FILE_NAME = "meta.cfg"
  # Author of the blog when none is given
  @@DEFAULT_AUTHOR = "Anonymous"

  # Public initialize a Blogpage
  #
  # title          - Title of the blog entry
  # blog_location  - Location of the Genablog
  # navlist        - List of pages to include in page header
  # default_author - Author to use if none given in config file
  #                  If not given, @@DEFAULT_AUTHOR will be used
  def initialize(title, blog_location, navlist, default_author=@@DEFAULT_AUTHOR)
    super(title, blog_location, navlist)
    @blog_entry_location = blog_location +
                           @@BLOG_ENTRY_DIRECTORY_LOCATION +
                           title +
                           "/"
    blog_entry_config_file_location = @blog_entry_location +
                                      @@BLOG_ENTRY_CONFIG_FILE_NAME

    @author = default_author.strip
    @date = Date.new
    @tags = Array.new

    # Read config file
    if File.file?(blog_entry_config_file_location)
      File.open(blog_entry_config_file_location).readlines.each do |line|
        line_split = line.strip.split(":")
        if line_split.length > 1
          case line_split[0].strip.downcase
          when "title" then @title = line_split[1].strip
          when "author" then @author = line_split[1].strip
          when "date"
            begin
              @date = Date.parse(line_split[1])
            rescue ArgumentError
              puts "Invalid date in #{blog_entry_config_file_location}"
            end
          when "tags" then @tags = line_split[1].split(",")
          end
        end
      end
    else
      puts "#{blog_entry_config_file_location} could not be read"
    end

  end

  # Public: Retrieve the blog page's tags
  #
  # Returns an array of strings containing tags
  def get_tags
    @tags
  end

  # Public: Retrieve the blog page's locations
  #
  # Returns a string containing blog page location
  def get_location
    @blog_entry_location
  end

  # Public: Retrieve the date that the blog page was created
  #
  # Returns a Data object containing the creation date
  def get_date
    @date
  end

  # Public: Retrieve the author of the blog page
  #
  # Returns a string containing the author's name
  def get_author
    @author
  end

  # Public: Prints the blog page's metadata
  #
  # Returns nothing
  def print
    puts "Blog Page #{@title}"
    puts "in blog: #{@blog_location}"
    puts "navlist: #{@navlist}"
    puts "author: #{@author}"
    puts "date: #{@date}"
    puts "tags: #{@tags}"
    puts "----------"
  end

end
