rbenv_gem "scout" do
  ruby_version node['scout']['rbenv_ruby_string']
  version node['scout']['version']
end

node['scout']['gem_packages'].each do |gem_name, gem_version|
  rbenv_gem gem_name do
    ruby_version node['scout']['rbenv_ruby_string']
    version gem_version if gem_version && gem_version.length > 0
  end
end
