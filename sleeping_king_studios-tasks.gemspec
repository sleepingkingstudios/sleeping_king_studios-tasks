# frozen_string_literal: true

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
  gem.files        =
    Dir['lib/**/*.erb', 'lib/**/*.rb', 'lib/**/*.thor', 'LICENSE', '*.md']

  gem.add_runtime_dependency 'thor', '>= 0.19.4', '< 2.0'
  gem.add_runtime_dependency 'sleeping_king_studios-tools', '~> 0.8'
  gem.add_runtime_dependency 'erubi', '~> 1.6'

  gem.add_development_dependency 'byebug',    '~> 9.0', '>= 9.0.6'
  gem.add_development_dependency 'rspec',     '~> 3.5'
  gem.add_development_dependency 'rspec-sleeping_king_studios',
    '~> 2.2', '>= 2.2.3'
  gem.add_development_dependency 'rubocop',   '~> 0.49.0'
  gem.add_development_dependency 'cucumber',  '~> 2.4'
  gem.add_development_dependency 'simplecov', '~> 0.14', '>= 0.14.1'
  gem.add_development_dependency 'simplecov-json', '~> 0.2'
end
