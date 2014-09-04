desc "Package cookbooks into a chef-solo tarball"
task :package do
  `mkdir -p pkg`
  `mkdir -p vendor/cookbooks/chef-asgard-config`
  `rsync --exclude .git --exclude pkg --exclude vendor -a . vendor/cookbooks/chef-asgard-config`
  version=`git describe --tags --abbrev=0`.strip
  tarball = "chef-asgard-config-#{version}.tar.gz"
  `rm -f pkg/#{tarball}`
  Dir.chdir 'vendor'
  puts "Building cookbook tarball #{tarball}"
  `tar czf ../pkg/#{tarball} cookbooks`
end
