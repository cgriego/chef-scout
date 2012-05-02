class ScoutCommand
  MissingKeyError = Class.new(ArgumentError)

  attr_reader :node

  def initialize(node)
    @node = node
  end

  def to_s
    [executable, key, arguments].join(" ").strip
  end

  def executable
    rvm? ? "/usr/local/rvm/bin/scout_scout" : "scout"
  end

  def rvm?
    node['scout']['rvm_ruby_string']
  end

  def key
    node['scout']['key'] or raise MissingKeyError
  end

  def arguments
    options.inject([]) do |array, (option, value)|
      array << %{--#{option} '#{value.gsub("'", "\\\\'")}'}
      array
    end.join(" ")
  end

  def options
    options = node['scout']['options'].to_hash
    options.merge!('name' => name) if name
    options
  end

  def name
    if node['scout']['name']
      node['scout']['name'].
      gsub("%{name}", node.to_hash['name']).
      gsub("%{chef_environment}", node.to_hash['chef_environment'])
    end
  end
end
