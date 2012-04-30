group node['scout']['group']

user node['scout']['user'] do
  comment "ScoutApp.com Agent"
  group node['scout']['group']
  home node['scout']['home']
  supports :manage_home => true
end
