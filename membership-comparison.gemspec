# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'membership_comparison/version'

Gem::Specification.new do |s|
  s.name = 'membership-comparison'
  s.version = MembershipComparison::VERSION
  s.summary = ''
  s.description = ''
  s.author = 'EveryPolitician'
  s.email = 'team@everypolitician.org'
  s.homepage = 'https://github.com/everypolitician/membership-comparison'
  s.license = 'MIT'

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- test/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map do |f|
    File.basename(f)
  end
  s.require_paths = ['lib']
end
