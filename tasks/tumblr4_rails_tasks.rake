require 'spec/rake/spectask'
require 'spec/translator'
 
namespace :tumblr4rails do
  
  desc 'Default: run specs.'
  task :default => :spec
 
  desc 'Run the Tumblr4Rails plugin specs'
  
  Spec::Rake::SpecTask.new(:spec) do |t|
    specdir = File.expand_path(File.join(File.dirname(__FILE__), "/../", "spec"))
    t.spec_opts = ['--options', "\"#{specdir}/spec.opts\""]
    t.spec_files = FileList["#{specdir}/**/*_spec.rb"]
    t.rcov = true
  end
  
end