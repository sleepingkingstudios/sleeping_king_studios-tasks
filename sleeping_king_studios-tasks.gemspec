# sleeping_king_studios-tasks.gemfile

$LOAD_PATH << './lib'

require 'sleeping_king_studios/tasks/version'

Gem::Specification.new do |gem|
  gem.name        = 'sleeping_king_studios-tasks'
  gem.version     = SleepingKingStudios::Tasks::VERSION
  gem.date        = Time.now.utc.strftime '%Y-%m-%d'
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
  gem.files        = Dir['lib/**/*.rb', 'LICENSE', '*.md']

  gem.add_runtime_dependency 'rake', '~> 12.0'
  gem.add_runtime_dependency 'thor', '~> 0.19', '>= 0.19.4'
  gem.add_runtime_dependency 'sleeping_king_studios-tools',
    '>= 0.7.0.alpha.0'

  gem.add_development_dependency 'erubis',  '~> 2.7.0'
  gem.add_development_dependency 'byebug',  '~> 9.0', '>= 9.0.6'
  gem.add_development_dependency 'rspec',   '~> 3.5'
  gem.add_development_dependency 'rspec-sleeping_king_studios',
    '~> 2.2', '>= 2.2.2'
  gem.add_development_dependency 'rubocop', '~> 0.47.0'
end # gemspec
