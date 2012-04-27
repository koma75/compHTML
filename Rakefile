require 'rake/clean'

SRCS = FileList["**/*.rb", "**/*.rbw"]
RUBY = "ruby"
DOC = "yardoc"
CC = "ocra"
DOCSRC = FileList["**/*.markdown"]
DOCHTM = DOCSRC.ext('html')

# Cleaning
CLEAN.include(".yardoc")
CLEAN.include(FileList["**/*.log"])
CLOBBER.include(DOCHTM)
CLOBBER.include("doc")
CLOBBER.include("compHTML.exe")

task :default => ["compHTML.exe"]

# OCRA COMPILATION
file 'compHTML.exe' => ["compHTML.rbw"] do
  sh "#{CC} compHTML.rbw"
end

# DOCUMENTATION 
task :doc => [:htmdoc, :yardoc]

task :yardoc => SRCS do |t|
  sh "#{DOC} --private --protected #{t.prerequisites.join(' ')} - #{DOCHTM}"
end

task :htmdoc => DOCHTM

rule '.html' => '.markdown' do |t|
  sh "#{RUBY} compHTML.rbw #{t.source}"
  mv t.source + ".html", t.name
end



