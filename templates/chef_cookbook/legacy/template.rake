# frozen_string_literal: true

task _COMMON_: ['default']

desc 'Run all tests'
task default: ['test']

desc 'Run all tests'
task test: ['test:static', 'test:unit', 'test:integration']

namespace :test do
  desc 'Run all static code analysis'
  task static: ['test:static:ruby', 'test:static:chef']

  namespace :static do
    desc 'Run rubocop analysis'
    task :ruby do
      sh('chef', 'exec', 'rubocop', '--display-cop-names', '--disable-pending-cops')
    end

    desc 'Run cookstyle analysis'
    task :chef do
      sh('chef', 'exec', 'cookstyle', '-c', '.cookstyle.yml', '--display-cop-names', '--disable-pending-cops')
    end
  end

  desc 'Run all unit tests'
  task unit: ['test:unit:spec']

  namespace :unit do
    desc 'Run rspec unit tests'
    task :spec do
      sh('rspec', '--format', 'documentation')
    end
  end

  desc 'Run all integration tests'
  task integration: ['test:integration:kitchen']

  namespace :integration do
    desc 'Run test-kitchen integration tests'
    task :kitchen do
      sh('kitchen', 'converge')
      sh('kitchen', 'verify')
    end
  end
end
