# Public: Contains the metadata of a Genablog web page
class Genablog::WebPage

  # Public: Initialize a web page
  #
  # title          - Title of the blog entry
  # blog_location  - Location of the Genablog
  # navlist        - List of pages to include in page header
  def initialize(title, blog_location, navlist)
    @title = title.strip
    @blog_location = blog_location
    @navlist = navlist
  end

  # Public: Prints the web page's metadata
  #
  # Returns nothing
  def print
    puts "Static Page #{@title}"
    puts "in blog: #{@blog_location}"
    puts "navlist: #{@navlist}"
    puts "----------"
  end

  # Public: Retrieves the page's title
  #
  # Returns the page's title as a string
  def get_title
    @title
  end

  # Public: Returns the name that this web pages's file should have
  #
  # Returns the page name as a string
  def get_page_name
    @title.gsub(/\s/,'_') + ".html"
  end
end
