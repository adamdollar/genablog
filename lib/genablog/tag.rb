# Public: Represents a Genablog tag
class Genablog::Tag

  # Public: Initialize a Genablog tag
  #
  # label - label of the tag
  def initialize(label)
    @label = label.strip
    @targets = Array.new
  end

  # Public: Add a reference to a blog entry to the tag
  #
  # target - Genablog::BlogPage to be referenced by tag
  #
  # Returns nothing
  def add_target(target)
    @targets.push target
  end

  # Public: Retreive the tag's label
  #
  # Returns label as a string
  def get_label
    @label
  end

  # Public: Retrieves the referenced blog pages
  #
  # Returns an array of BlogPages referenced by tag
  def get_targets
    @targets
  end

  # Public: Print the tag's contents
  #
  # Returns nothing
  def print
    puts "Tag #{@label}:"
    @targets.each { |target| puts target }
    puts "----------"
  end

  # Public: Returns the name that a tag page for this tag should have
  #
  # Returns the page name as a string
  def get_page_name
    @label.gsub(/\s/,'_') + ".html"
  end

end
