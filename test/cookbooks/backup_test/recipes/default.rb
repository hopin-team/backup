#
# Cookbook Name:: backup
# Recipe:: default
#
# Copyright 2014, Scott M. Likens
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

package "ruby-full" 
backup_install node.name 
backup_generate_config node.name

gem_package "fog" do
  version "~> 1.4.0"
end

backup_generate_model "archive" do
  description "backup of /etc"
  backup_type "archive"
  split_into_chunks_of 250
  store_with({"engine" => "Local", "settings" => { "local.keep" => 5, "local.path" => "/tmp" } })
  options({"add" => ["/home/","/etc/"], "exclude" => ["/etc/init"], "tar_options" => "-p"})
  mailto "sample@example.com"
  action :backup
  gem_bin_dir "/usr/local/bin"
end

execute "perform backup test on archive" do
  command "/usr/local/bin/backup perform -t archive -c /opt/backup/config.rb"
end

backup_generate_model "archive_encrypted" do
  description "backup of /etc encrypted" 
  backup_type "archive"
  encrypt_with({"engine" => "OpenSSL", "settings" => { "encryption.password" => "kitchen", "encryption.base64" => "true", "encryption.salt" => "true"}})
  store_with({"engine" => "Local", "settings" => { "local.keep" => 5, "local.path" => "/tmp" } })
  options({"add" => ["/home/","/etc/"], "exclude" => ["/etc/init"], "tar_options" => "-p"})
  gem_bin_dir "/usr/local/bin"
  action :backup
end

execute "perform backup test on archive_encrypted" do
  command "/usr/local/bin/backup perform -t archive_encrypted -c /opt/backup/config.rb"
end
  
backup_generate_model "no_split_test" do
  description "backup of /etc"
  backup_type "archive"
  store_with({"engine" => "Local", "settings" => { "local.keep" => 5, "local.path" => "/tmp" } })
  options({"add" => ["/home/","/etc/"], "exclude" => ["/etc/init"], "tar_options" => "-p"})
  mailto "sample@example.com"
  action :backup
  gem_bin_dir "/usr/local/bin"
end

execute "backup now no_split_test" do
  command "/usr/local/bin/backup perform -t no_split_test -c /opt/backup/config.rb"
end

backup_generate_model "archive_attribute_test" do
  description "backup of /etc using additional attributes"
  backup_type "archive"
  split_into_chunks_of 250
  store_with({"engine" => "Local", "settings" => { "local.keep" => 5, "local.path" => "/tmp" } })
  options({"add" => ["/home/","/etc/"], "exclude" => ["/etc/init"], "tar_options" => "-p"})
  mailto "sample@example.com"
  action :backup
  notify_by({"method" => "Campfire", "settings" => {"campfire.on_success" => "true", "campfire.on_warning" => "true", "campfire.on_failure" => "true", "campfire.api_token" => "token", "campfire.subdomain" => "domain", "campfire.room_id" => '34' }})
  gem_bin_dir "/usr/local/bin"
  cron_path "/bin:/usr/bin:/usr/local/bin:/opt/chef/embedded/bin"
  cron_log "/var/log/backups.log"
  tmp_path "/opt/tmp/backups"
end

execute "backup now archive_attribute_test" do
  command "/usr/local/bin/backup perform -t archive_attribute_test -c /opt/backup/config.rb"
end

# Need rsync package
package 'rsync'
backup_generate_model "sync_with_test" do
  description "Test Syncers locally (with RSync::Local)"
  backup_type "syncer"
  action :backup
  gem_bin_dir "/usr/local/bin"
  options "add" => ["/opt/backup"],
          "exclude" => ["log*"]
  sync_with "syncer" => "RSync::Local",
            "settings" => { "syncer.path" => "/tmp/sync",
                            "syncer.mirror" => true }
end

execute "backup now sync_with_test" do
  command "/usr/local/bin/backup perform -t sync_with_test -c /opt/backup/config.rb"
end
