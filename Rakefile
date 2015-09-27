require 'xcpretty'

namespace :test do

  desc "Run Transporter Tests for iOS"
  task :ios do
    $ios_success = system("set -o pipefail && xcodebuild clean test -scheme 'Tests-iOS' -destination 'name=iPhone 6s' | xcpretty -tc")
  end

  desc "Run Transporter Tests for Mac OS X"
  task :osx do
    $osx_success = system("set -o pipefail && xcodebuild clean test -scheme 'Tests-OSX' | xcpretty -tc")
  end
end

desc "Run Transporter Tests for iOS & Mac OS X"
task :test => ['test:ios', 'test:osx'] do
  puts "\033[0;31m! iOS unit tests failed" unless $ios_success
  puts "\033[0;31m! OS X unit tests failed" unless $osx_success
  if $ios_success && $osx_success
    puts "\033[0;32m** All tests executed successfully"
    exit(0)
  else
    exit(-1)
  end
end

task :default => 'test'
