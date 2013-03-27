#
# Author:: Marius Ducea (marius@promethost.com)
# Cookbook Name:: nodejs
# Recipe:: source
#
# Copyright 2010-2012, Promet Solutions
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

remote_file                = node.pgbouncer.source.url
local_file                 = remote_file.gsub(%r{.*/}, '')        # pgbouncer-1.5.4.tar.gz
local_dir                  = local_file.gsub(%r{\.tar\.gz}, '')   # pgbouncer-1.5.4

node[:pgbouncer][:version] = local_dir.gsub(%r{.*-}, '')       # 1.5.4

remote_file "#{Chef::Config[:file_cache_path]}/#{local_file}" do
	source remote_file
	mode "0744"
	not_if { File.directory?("#{Chef::Config[:file_cache_path]}/#{local_dir}") }
end

package_file = "#{Chef::Config[:file_cache_path]}/#{local_file}"

execute "extract tar ball into file_cache_path" do
  command "cd #{Chef::Config[:file_cache_path]} && tar -xzvf #{package_file}"
  not_if { File.directory?("#{Chef::Config[:file_cache_path]}/#{local_dir}") }
end


case node['platform']
  when 'smartos'
    execute "build pgbouncer" do
      command [
        "cd #{Chef::Config[:file_cache_path]}/#{local_dir}",
        "./configure 'CFLAGS=-m64' 'CXXFLAGS=-m64' 'LDFLAGS=-m64' --with-libevent=/opt/local --prefix=#{node.pgbouncer.source.install_dir}",
        "make install"
      ].join(" && ")
      not_if { File.exists?("#{node.pgbouncer.source.install_dir}/bin/pgbouncer") }
    end

    smf "pgbouncer" do
      start_command "#{node.pgbouncer.source.install_dir}/bin/pgbouncer -d -u #{node.pgbouncer.os_user} /etc/pgbouncer/pgbouncer.ini"
      refresh_command ":kill -HUP"
      stop_command ":kill"
      environment "LD_LIBRARY_PATH" => "/opt/local/lib"
      start_timeout 30
      stop_timeout 30
      working_directory "/"
    end

  else
    execute "build pgbouncer" do
      command [
        "cd #{Chef::Config[:file_cache_path]}/#{local_dir}",
        "./configure --prefix=#{node.pgbouncer.source.install_dir}",
        "make install"
      ].join(" && ")
      not_if { File.exists?("#{node.pgbouncer.source.install_dir}/bin/pgbouncer") }
    end
end

