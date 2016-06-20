$LOAD_PATH.push(File.join(File.dirname(__FILE__), 'lib'))
require 'bundler/gem_tasks'
require 'bicho/version'
require 'rake/testtask'

extra_docs = ['README*', 'TODO*', 'CHANGELOG*']

task default: [:test]

Rake::TestTask.new do |t|
  t.libs << File.expand_path('../test', __FILE__)
  t.libs << File.expand_path('../', __FILE__)
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new(:doc) do |t|
    t.files   = ['lib/**/*.rb', *extra_docs]
    t.options = ['--no-private']
  end
rescue LoadError
  STDERR.puts 'Install yard if you want prettier docs'
  require 'rdoc/task'
  Rake::RDocTask.new(:doc) do |rdoc|
    rdoc.rdoc_dir = 'doc'
    rdoc.title = "bicho #{Bicho::VERSION}"
    extra_docs.each { |ex| rdoc.rdoc_files.include ex }
  end
end
