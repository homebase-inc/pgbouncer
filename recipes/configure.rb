service "pgbouncer" do
  action :nothing
  supports :status => true, :start => true, :stop => true, :restart => true, :reload => true
end

directory "/etc/pgbouncer" do
  owner node.pgbouncer.os_user
  mode "0755"
  not_if { File.directory?("/etc/pgbouncer") }
end

template "/etc/pgbouncer/pgbouncer.ini" do
  source "pgbouncer.ini.erb"
  owner node.pgbouncer.os_user
  group node.pgbouncer.os_group
  mode "644"
  notifies :reload, resources(:service => "pgbouncer")
end

template "/etc/pgbouncer/userlist.txt" do
  source "userlist.txt.erb"
  owner node.pgbouncer.os_user
  group node.pgbouncer.os_group
  mode "644"
  notifies :reload, resources(:service => "pgbouncer")
end

template "/etc/default/pgbouncer" do
  source "pgbouncer.default.erb"
  owner node.pgbouncer.os_user
  group node.pgbouncer.os_group
  mode "644"
  notifies :reload, resources(:service => "pgbouncer")
end

[node.pgbouncer.logfile].each do |file_name|
  file file_name do
    owner node.pgbouncer.os_user
    group node.pgbouncer.os_group
    mode "644"
    action :create_if_missing
  end
end

service "pgbouncer" do
  action [:enable, :start]
end
