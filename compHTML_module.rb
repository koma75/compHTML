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
require 'logger'
require 'kconv'

module CompHTML
  # The Configuration class
  class Config
    DefaultCssFile = "compHTML.css"

    # Default CSS File Reader function
    def self.DefaultCssFile
      return DefaultCssFile
    end

    # Initialization of Config class
    # Reads the specified :iniFile and populate the configuration 
    # parameters
    # MAY BREAK if executed after changing the working directory
    def initialize(opts={})
      opts = {
        :iniFile=>"config.ini", 
        :log=>nil
      }.merge(opts)
      @log = opts[:log] || Logger.new(STDERR)

      iniFile = opts[:iniFile]
      # Set Directory path settings
      if is_OcraCompiled() # needs to obtain exePath from env
        @exePath = File.dirname(ENV["OCRA_EXECUTABLE"])
        log.debug "running as ocra executive"
      else
        @exePath = File.dirname(File.expand_path($0))
        log.debug "running as ruby script"
      end
      log.debug "@exePath = #{@exePath}"

      # Expand the path if iniFile specified with a relative path
      if File.dirname(iniFile)[0] == "."  # is a relative path
        # assume path is relative to exe path
        iniFile = File.expand_path(iniFile, @exePath)
      end
      log.debug "using config file path :#{iniFile}"

      # Set default values.
      @rndrOpt = {:hard_wrap => false,
                  :xhtml => true,
                  :with_toc_data => true}
      @markdownExt = {:autolink => true, 
                      :tables => true,
                      :fenced_code_blocks => true,
                      :autolink => true,
                      :superscript => true,
                      :strikethrough => true,
                      :no_intra_emphasis => true}

      # if iniFile was a 0 length string, it should be expanded
      # at this point with the @exePath
      if File.file?(iniFile) and File.exists?(iniFile)
        # TODO: properly parse ini file and populate settings
        # No current support, so just use default values
        @cssFile = File.expand_path(DefaultCssFile, @exePath)

        # For hash options, we should do something like the following
        # rndrIni = Hash.new
        # extIni = Hash.new
        # rndrIni.store(:someopt, true) #while parsing ini file
        #
        # and merge with default values(which will override the old
        # with new ones)
        # @rndrOpt.merge! rndrIni
        # @markdownExt.merge! extIni
      else
        @cssFile = File.expand_path(DefaultCssFile, @exePath)
      end
      log.debug "@cssFile :#{@cssFile}"
    end # initialize
    attr_reader :log
    attr_accessor :cssFile, :exePath, :rndrOpt, :markdownExt

    # Checks if executive is compiled using ocra
    def is_OcraCompiled()
      if ENV["OCRA_EXECUTABLE"].nil?
        return false
      else
        return true
      end
    end
    private :is_OcraCompiled
  end # Config Class

  # Markdown Engine used to compile markdown text inputs
  class Engine
    # Initialization for the Markdown Engine
    # :config used to configure the Engine
    def initialize(opts={})
      opts = {
        :log=>nil, 
        :config=>nil
      }.merge(opts)
      @log = opts[:log] || Logger.new(STDERR)
      config = opts[:config] || CompHTML::Config.new(:log=>@log)
 
      ####################################################################
      # Initialization of Redcarpet
      @rndr = Redcarpet::Render::HTML.new(config.rndrOpt)
      @markdown = Redcarpet::Markdown.new(@rndr,config.markdownExt)

      self.setCSS_to(config.cssFile)
    end
    attr_reader :log

    # reset the css to specified css
    def setCSS_to(css_filename = "")
      if css_filename.length > 0 and File.exists?(css_filename)
        @css = createCSSinsert(css_filename)
      else
        @css = ""
      end
    end

    # Create HTML header with html:title attribute set to :title
    def createHTMLhead(opts={})
      opts = {
        :title=>"Markdown HTML"
      }.merge(opts)
      title = opts[:title]
      htmlHeader = <<-EOS
        <!DOCTYPE html>

        <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
          <head>
            <meta http-equiv="content-type" content="text/html;charset=UTF-8" />
            <title>#{title}</title>
          </head>
         
          <body>
      EOS
      log.debug "HTML Title set to : #{Kconv.tosjis(title)}"
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
    # Assumes that inFile is available.
    def createCSSinsert(inFile)
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
      log.debug "CSS input file : #{inFile}"
      return cssOut
    end
    private :createCSSinsert

    # Generates the HTML output with the specified inputs
    # :outFile : Output HTML file name
    # :title : Title used within the HTML title attribute
    # :markdownTXT : string of markdown formatted text to parse and create 
    #   the body of the HTML file
    def generateHtml(opts={})
      opts = {
        :outFile=>"", 
        :title=>"Markdown HTML", 
        :markdownTXT=>""
      }.merge(opts)
      outFile = opts[:outFile]
      title = opts[:title]
      markdownTXT = opts[:markdownTXT]

      # Write the final output
      log.debug "generating HTML for :#{outFile}"
      if outFile == nil or outFile.length == 0
        puts "ERROR: output filename invalid"
        return
      end
      if markdownTXT == nil
        puts "ERROR: no markdown text specified"
        return
      end

      # we want to replace the old html file
      # TODO: this might be better off being an option
      if File.exist?(outFile)
        File.delete(outFile)
      end
      foHtml = open(outFile,'a')

      # Finally generate the html output
      foHtml.puts createHTMLhead(:title=>title)
      foHtml.puts @css
      foHtml.puts @markdown.render(markdownTXT)
      foHtml.puts createHTMLfoot()

      foHtml.close
    end
  end #Engine Class

  # File Reader to prepare for the CompHTML::Engine use
  class Reader
    # Initialize Reader class with the inputFile.
    # Reads the :inFile and populate the instance variables for later use
    def initialize(opts={})
      opts = {
        :inFile=>"", 
        :log=>nil
      }.merge(opts)
      @log = opts[:log] || Logger.new(STDERR)

      inputFile = opts[:inFile]

      log.debug "Reading : #{inputFile}"
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
    attr_reader :log
    attr_accessor :fileTitle, :fileBody, :outputName
  end  # Reader Class
end

