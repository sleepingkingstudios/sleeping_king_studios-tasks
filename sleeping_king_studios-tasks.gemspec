# sleeping_king_studios-tasks.gemfile

$: << './lib'

require 'sleeping_king_studios/tasks/version'

Gem::Specification.new do |gem|
  gem.name        = 'sleeping_king_studios-tasks'
  gem.version     = SleepingKingStudios::Tasks::VERSION
  gem.date        = Time.now.utc.strftime "%Y-%m-%d"
  gem.summary     = 'A tasks toolkit for rapid development.'

  description = <<-DESCRIPTION
    Toolkit providing an encapsulation layer around the Thor CLI library, with
    predefined tasks for development and continuous integration.
  DESCRIPTION
  gem.description = description.strip.gsub(/\n +/, ' ')
  gem.authors     = ['Rob "Merlin" Smith']
  gem.email       = ['merlin@sleepingkingstudios.com']
  gem.homepage    = 'http://sleepingkingstudios.com'
  gem.license     = 'MIT'

  gem.require_path = 'lib'
  gem.files        = Dir["lib/**/*.rb", "LICENSE", "*.md"]

  gem.add_runtime_dependency 'rake', '~> 12.0'
  gem.add_runtime_dependency 'thor', '~> 0.19',  '>= 0.19.4'
end # gemspec
