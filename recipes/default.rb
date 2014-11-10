
include_recipe "pgbouncer::install_from_#{node[:pgbouncer][:install_method]}"
include_recipe 'pgbouncer::configure'
