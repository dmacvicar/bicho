$:.push(File.join(File.dirname(__FILE__), 'lib'))
require 'bundler/gem_tasks'
require 'bicho/version'
require 'rake/rdoctask'

extra_docs = ['README*', 'TODO*', 'CHANGELOG*']

begin
 require 'yard'
  YARD::Rake::YardocTask.new(:doc) do |t|
    t.files   = ['lib/**/*.rb', *extra_docs]
  end
rescue LoadError
  STDERR.puts "Install yard if you want prettier docs"
  Rake::RDocTask.new(:doc) do |rdoc|
    rdoc.rdoc_dir = "doc"
    rdoc.title = "bicho #{Bicho::VERSION}"
    extra_docs.each { |ex| rdoc.rdoc_files.include ex }
  end
end
