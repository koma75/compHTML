#! ruby
# encoding: utf-8
#
#Copyright (c) 2012, Koma <okunoya@path-works.net>
#All rights reserved.
#
#Redistribution and use in source and binary forms, with or without 
#modification, are permitted provided that the following conditions are met:
#
#* Redistributions of source code must retain the above copyright notice, 
#  this list of conditions and the following disclaimer.
#* Redistributions in binary form must reproduce the above copyright notice, 
#  this list of conditions and the following disclaimer in the documentation
#  and/or other materials provided with the distribution.
#
#THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
#AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
#ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
#LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
#CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
#SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
#INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
#CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
#ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
#POSSIBILITY OF SUCH DAMAGE.
#
#compHTML: a simple tool to compile a markdown script to a standalone HTML
#
#This program uses/derives from the following works:
#* redcarpet
#  * https://github.com/tanoku/redcarpet
#* clownfart Markdown-CSS
#  * https://github.com/clownfart/Markdown-CSS

require 'logger'
require 'bundler/setup'
require File.join(File.expand_path(File.dirname(__FILE__)), 'compHTML_module.rb')
require 'wx'
require 'filewatcher'

# Output log filename
LOGFILE_NAME = 'compHTML.log'

#
# GUI Dialogue class to allow File OPEN dialogs
#
class MyGUI < Wx::App
  @files
  attr_reader :files

  private

  #
  # Open a File Open Dialog to select files to convert.
  #
  def on_init
    fd = Wx::FileDialog.new(
                nil,          # parent
                "Open File",  # message
                "",           # defaultDir
                "",           # defaultFile
                "*.txt;*.markdown;*.md",           # wildcard
                (Wx::FD_OPEN | Wx::FD_MULTIPLE))
    if fd.show_modal == Wx::ID_OK
      @files = fd.get_paths
    end
    return false
  end
end

#
# File watching dialog class
#
class MyWatcher < Wx::App
  # list of files to watch
  @files = []
  # logger object
  @log
  # Redcarpet engine used to update changed files
  @myEngine
  attr_accessor :files, :log, :myEngine

  #
  # Set the files to watch
  #
  def set_files(flist)
    @files = flist
    if @files.nil?
      @files = []
    end
  end

  private

  #
  # Start a thread to watch for changes in input file and run redcarpet
  # on every change.  Keep watching until the dialog is closed.
  #
  def on_init
    Wx::Timer.every(55) { Thread.pass }
    if @files.size > 0
      message = "watching files:\n"
      @files.each {|x|
        message << x
        message << "\n"
      }
      t = Thread.new(@files) do |flist|
        FileWatcher.new(flist).watch do |filename|
          myReader = CompHTML::Reader.new(:log=>@log, :inFile=>filename)
          @myEngine.generateHtml(:outFile=>myReader.outputName,
                                :title=>myReader.fileTitle,
                                :markdownTXT=>myReader.fileBody)
        end
      end
      Wx::message_box(message)
      Thread::kill(t)
    end
    return false
  end
end

if defined?(Ocra)
  exit 0
end
if $0 == __FILE__
  # Create the logging object
  exePath = CompHTML::Config.getExePath() # needs to obtain exePath from env

  log = Logger.new(File.expand_path(LOGFILE_NAME, exePath))
  log.level = Logger::INFO

  # Create the default config class
  myConfig = CompHTML::Config.new(:log=>log)

  # Parse input arguments.
  myGUI = nil
  files = []
  if (ARGV.length > 0)
    ARGV.each do |x|
      files.push(x)
    end

    # TODO: Add an option to specify ini file. may not be very important

    # TODO: Add an option to directly specify CSS File to use
    #   may be useful to parse the file names for *.css and 
    #   override instead of using command line options.
    #   This way we can just drag-n-drop all the files *with*
    #   the CSS file.
  else
    #
    # If no arguments are given, launch in GUI mode.
    #
    myGUI = MyGUI.new
    myGUI.main_loop
    files = myGUI.files
    if files.nil?
      files = []
    end
  end

  if files.size == 0
    # No files to parse
    # Should go into GUI mode in v2.x
    exit 0
  end

  # Initialize the CompHTML::Engine first
  myEngine = CompHTML::Engine.new(:log=>log, :config=>myConfig)

  # Run each input file through the Engine
  files.each do |filename|
    begin
      myReader = CompHTML::Reader.new(:log=>log, :inFile=>filename)
      myEngine.generateHtml(:outFile=>myReader.outputName,
                            :title=>myReader.fileTitle,
                            :markdownTXT=>myReader.fileBody)
    rescue => ex
      log.error ex
    end
  end

  #
  # If the program was run on GUI mode, start a watch on the files
  #
  if not myGUI.nil?
    myWatcher = MyWatcher.new
    myWatcher.set_files(files)
    myWatcher.log = log
    myWatcher.myEngine = myEngine
    myWatcher.main_loop
  end

end

