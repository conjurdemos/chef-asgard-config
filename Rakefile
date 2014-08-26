desc "Package cookbooks into a chef-solo tarball"
task :package do
  `mkdir -p vendor/cookbooks/asgard-config`
  `cp -r metadata.rb recipes templates vendor/cookbooks/asgard-config`
  version=`git describe --tags --abbrev=0`.strip
  Dir.chdir 'vendor'
  tarball = "asgard-config-#{version}.tar.gz"
  puts "Building cookbook tarball #{tarball}"
  `tar czf ../#{tarball} cookbooks`
end
