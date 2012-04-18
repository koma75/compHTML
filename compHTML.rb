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

require 'redcarpet'
require 'kconv'

module CompHTML
  # The Configuration class
  class Config
    DefaultCssFile = "compHTML.css"

    # Default CSS File Reader function
    def self.defaultCSS
      return DefaultCssFile
    end

    # Initialization of Config class
    # Reads the specified iniFile and populate the configuration 
    # parameters
    def initialize(iniFile = "config.ini")
      if iniFile.length > 0 and File.exists?(iniFile)
        # TODO: properly parse ini file and populate settings
        # No current support, so just use default values
        @cssFile = DefaultCssFile
      else
        @cssFile = DefaultCssFile
      end
    end
    attr_accessor :cssFile
  end

  # Markdown Engine used to compile markdown text inputs
  class Engine
    # Initialization for the Markdown Engine
    # css_filename : css file to use to create the CSS portion of the HTML
    def initialize(config)
      ####################################################################
      # Initialization of Redcarpet
      # TODO: move all the relevant options to config
      @rndr = Redcarpet::Render::HTML.new(:hard_wrap => true,
                                         :xhtml => true,
                                         :with_toc_data => true)
      @markdown = Redcarpet::Markdown.new(@rndr, 
                                         :autolink => true, 
                                         :tables => true,
                                         :fenced_code_blocks => true,
                                         :autolink => true,
                                         :superscript => true,
                                         :strikethrough => true,
                                         :no_intra_emphasis => true)

      self.setCSS_to(config.cssFile)
    end

    # reset the css to specified css
    def setCSS_to(css_filename = "")
      if css_filename.length > 0 and File.exists?(css_filename)
        @css = createCSSinsert(css_filename)
      else
        @css = ""
      end
    end

    # Create HTML header with html:title attribute set to title
    def createHTMLhead(title = "Markdown HTML")
      htmlHeader = <<-EOS
        <!DOCTYPE html>

        <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
          <head>
            <meta http-equiv="content-type" content="text/html;charset=UTF-8" />
            <title>#{title}</title>
          </head>
         
          <body>
      EOS
      return htmlHeader
    end
    private :createHTMLhead

    # Create HTML footer
    def createHTMLfoot()
      footer = <<-EOS
          </body>
        </html>
      EOS
      return footer
    end
    private :createHTMLfoot

    # Create CSS insert
    # this method will return a zero length string if no input is specified
    def createCSSinsert(inFile = "")
      cssOut = ""
      fiCSS = File.open(inFile)
      cssOut = <<-EOS
        <style type="text/css">
        <!--
      EOS
      cssOut += Kconv.toutf8(fiCSS.read())
      cssOut += <<-EOS
        -->
        </style>
      EOS
      return cssOut
    end
    private :createCSSinsert

    # Generates the HTML output with the specified inputs
    # outFile : Output HTML file name
    # title : Title used within the HTML title attribute
    # markdownTXT : string of markdown formatted text to parse and create 
    #   the body of the HTML file
    def generateHtml(outFile = "", title = "Markdown HTML", markdownTXT = "")
      # Write the final output
      if outFile == nil or outFile.length == 0
        puts "ERROR: output filename invalid"
        return
      end
      if markdownTXT == nil
        puts "ERROR: no markdown text specified"
        return
      end
      puts "outputting HTML: " + outFile
      puts "Title: " + Kconv.tosjis(title)

      # we want to replace the old html file
      # TODO: this might be better off being an option
      if File.exist?(outFile)
        File.delete(outFile)
      end
      foHtml = open(outFile,'a')

      # Finally generate the html output
      foHtml.puts createHTMLhead(title)
      foHtml.puts @css
      foHtml.puts @markdown.render(markdownTXT)
      foHtml.puts createHTMLfoot()

      foHtml.close
    end
  end #Engine Class

  # File Reader to prepare for the CompHTML::Engine use
  class Reader
    # Initialize Reader class with the inputFile.
    # Reads the inputFile and populate the instance variables for later use
    def initialize(inputFile = "")
      # Read the input file and obtain first line for HTML Title
      @fileTitle = ""
      @fileBody = ""
      @outputName = ""

      if inputFile.length > 0 and File.exists?(inputFile)
        @outputName = inputFile + "\.html"

        f = open(inputFile)
        @fileBody = Kconv.toutf8(f.read)
        f.close

        @fileBody.each_line{|line|
          # TODO: are there any better way for this...?
          @fileTitle = line.chomp
          break
        }
      else
        raise "ERROR: Input file '#{Kconv.tosjis(inputFile)}' does not exist!"
      end
    end

    attr_accessor :fileTitle, :fileBody, :outputName
  end  # FileReader Class
end

# Program Constants
ProgramName = "compHTML"
Usage = <<-EOS
No Input file to parse

Usage: #{ProgramName} [File] [File ...]
    Parses each input [File] as markdown text and outputs an HTML file
    including the CSS file specified in the settings
    (settings are currently unsupported and defaults to #{CompHTML::Config.defaultCSS})
EOS

if $0 == __FILE__
  # Parse input arguments.
  files = []
  myConfig = CompHTML::Config.new()
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
    # no input file so exit
    puts Usage
    exit -1
  end

  # Initialize the CompHTML::Engine first
  myEngine = CompHTML::Engine.new(myConfig)

  # Run each input file through the Engine
  files.each do |filename|
    begin
      myReader = CompHTML::Reader.new(filename)
      myEngine.generateHtml(myReader.outputName, myReader.fileTitle, myReader.fileBody)
    rescue => ex
      puts ex
    end
  end

end

