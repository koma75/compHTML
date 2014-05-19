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
require 'kconv'
require 'bundler/setup'
# GEMS
require 'redcarpet'
require 'boolean'
require 'inifile'

# @author Koma
module CompHTML
  # The Configuration class
  class Config
    DefaultCssFile = "compHTML.css"
    @@exePath = nil

    # Default CSS File Reader function
    def self.DefaultCssFile
      return DefaultCssFile
    end

    # @param [Hash] opts
    # @option opts [String] :iniFile ('config.ini') Configuration file
    # @option opts [Logger] :log (nil) Logger used for logging. creates own
    #   logger with output to STDERR if nil.
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

      # just in case iniFile is an empty string...
      if iniFile.empty? 
        raise "Config object initialized with zero length file name!"
      end

      # Set Directory path settings
      @exePath = CompHTML::Config.getExePath()
      log.debug "@exePath = #{@exePath}"

      # Expand the path if iniFile specified with a relative path
      if File.dirname(iniFile)[0] == "."  # is a relative path
        # assume path is relative to exe path
        iniFile = File.expand_path(iniFile, @exePath)
      end
      log.debug "using config file path :#{iniFile}"

      begin
        readConfiguration(iniFile)
      rescue => exc
        # 対象のiniファイルが無ければデフォルト値で生成する
        log.debug exc
        log.info "creating default ini file as #{iniFile}"
        create_default_inifile(:filename=>iniFile)
        retry
      end
    end

    attr_reader :log
    attr_accessor :cssFile, :exePath, :rndrOpt, :markdownExt

    # @param [String] iniFile config file path to read
    # 設定ファイルを読みだして設定変数に値をセットします
    def readConfiguration(iniFile)
      # 対象のiniファイルが無ければデフォルト値で生成する
      unless File.exist?(iniFile)
        raise "No such File: #{iniFile}"
      end

      ini = IniFile.load(iniFile)
      iniPath = File.dirname(iniFile)

      ###############################################
      # Parse the global section
      @cssFile = ini["global"]["cssFile"]
      if @cssFile.nil?
        @cssFile = DefaultCssFile
      end
      if File.dirname(@cssFile)[0] == "."
        # css file will be set relative to config file
        @cssFile = File.expand_path(@cssFile, iniPath)
      end

      ###############################################
      # Parse the renderOpt and markdownExt section
      @rndrOpt = parse_section(ini, "renderOpt", :to_bool=>true)
      @markdownExt = parse_section(ini, "markdownExt", :to_bool=>true)

      log.debug "Config initialized:"
      log.debug "  @cssFile = #{@cssFile}"
      log.debug "  @rndrOpt = #{@rndrOpt}"
      log.debug "  @markdownExt = #{@markdownExt}"
    end

    # @param [Hash] opts
    # @option opts [String] :filename ('config.ini') Configuration file 
    #   name to create
    # :filenameで指定したファイル名のiniファイルを生成し、デフォルト値
    # を書き込みます。
    def create_default_inifile(opts={})
      opts={
        :filename=>"config.ini"
      }.merge(opts)
      ini = IniFile.new(opts[:filename])
      global = {
        :cssFile=>"compHTML.css"
      }
      renderOpt = {:hard_wrap => "false",
                  :xhtml => "true",
                  :with_toc_data => "true"}
      markdownExt = {:autolink => "true", 
                      :tables => "true",
                      :fenced_code_blocks => "true",
                      :autolink => "true",
                      :superscript => "true",
                      :strikethrough => "true",
                      :no_intra_emphasis => "true"}
      ini["global"] = global
      ini["renderOpt"] = renderOpt
      ini["markdownExt"] = markdownExt
      ini.save
    end
    private :create_default_inifile

    # @param [IniFile] ini IniFile to parse from
    # @param [String] sect ("global") The Section of ini file to parse
    # @param [Hash] opts
    # @option opts [Boolean] to_bool (false) turns all value to Boolean 
    #   when true.  This option will override other options.
    # @option opts [Boolean] to_symbol (false) turns all value to symbol
    #   when true.
    # Parse IniFile object for section :sect
    def parse_section(ini, sect="global", opts={})
      opts={
        :to_bool=>false,
        :to_symbol=>false
      }.merge(opts)
      settings = {}
      ini[sect].each_pair {|k, v|
        if opts[:to_bool]
          value = v.to_b
        elsif opts[:to_symbol]
          value = v.intern
        else
          value = v
        end
        settings[k.intern] = value
      }
      return settings
    end
    private :parse_section

    # @return [String] Returns the absolute path to the executable
    # obtain the exe path.  Only works BEFORE CURRENT DIRECTORY CHANGE
    def self.getExePath()
      unless @@exePath.nil?
        return @@exePath
      end

      if CompHTML::Config.is_OcraCompiled() # needs to obtain exePath from env
        @@exePath = File.dirname(ENV["OCRA_EXECUTABLE"])
        return @@exePath
      else
        @@exePath = File.dirname(File.expand_path($0))
        return @@exePath
      end
    end

    # @return [True] returns true if it is an OCRA compiled version
    # @return [False] returns false if it is not compiled by OCRA
    # Checks if executive is compiled using ocra
    def self.is_OcraCompiled()
      if ENV["OCRA_EXECUTABLE"].nil?
        return false
      else
        return true
      end
    end
  end # Config Class

  # Markdown Engine used to compile markdown text inputs
  class Engine
    # @param [Hash] opts
    # @option opts [Config] :config (nil) config object used to configure 
    #   the Engine.  Creates a new Default Config object if nil.
    # @option opts [Logger] :log (nil) Logger used for logging. creates own
    #   logger with output to STDERR if nil.
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

    # @param css_filename Path to the CSS File to read
    # reset the css to specified css
    def setCSS_to(css_filename = "")
      log.debug "setCSS_to: #{css_filename}"
      if css_filename.length > 0 and File.exist?(css_filename)
        @css = createCSSinsert(css_filename)
      else
        @css = ""
      end
    end

    # @param [Hash] opts
    # @option opts [String] :title ("Markdown HTML") Title of the HEAD element
    # @option opts [String] :css ("") CSS insert string inside HEAD
    # @return [String] returns the HTML header portion
    # Create HTML header with html:title attribute set to :title
    def createHTMLhead(opts={})
      opts = {
        :title=>"Markdown HTML",
        :css=>""
      }.merge(opts)
      title = opts[:title]
      htmlHeader = <<-EOS
        <!DOCTYPE html>

        <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
          <head>
            <meta http-equiv="content-type" content="text/html;charset=UTF-8" />
            <title>#{title}</title>
            #{opts[:css]}
          </head>
         
          <body>
      EOS
      log.debug "HTML Title set to : #{Kconv.tosjis(title)}"
      return htmlHeader
    end
    private :createHTMLhead

    # @return [String] returns the HTML footer portion
    # Create HTML footer
    def createHTMLfoot()
      footer = <<-EOS
          </body>
        </html>
      EOS
      return footer
    end
    private :createHTMLfoot

    # @param [String] inFile input CSS File path
    # @return [String] returns the CSS insertion string
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

    # @param [Hash] opts
    # @option opts [String] :outFile ("") output filename in full or relative path
    # @option opts [String] :title ("Markdown HTML") HTML title
    # @option opts [String] :markdownTXT ("") markdown text to parse for body
    # Generates the HTML output with the specified inputs
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
      foHtml.puts createHTMLhead(:title=>title, :css=>@css)
      foHtml.puts @markdown.render(markdownTXT)
      foHtml.puts createHTMLfoot()

      foHtml.close
    end
  end #Engine Class

  # File Reader to prepare for the CompHTML::Engine use
  class Reader
    # @param [Hash] opts
    # @option opts [String] :inFile ("") Path to the file to read.
    # @option opts [Logger] :log (nil) Logger used for logging. creates own
    #   logger with output to STDERR if nil.
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

      if inputFile.length > 0 and File.exist?(inputFile)
        @outputName = inputFile.sub(/\.[a-zA-Z0-9_\-]+$/, "\.html")

        f = open(inputFile)
        @fileBody = Kconv.toutf8(f.read)
        f.close

        @fileBody =~ /(.*)[\n\r]/
        @fileTitle = $1
      else
        raise "ERROR: Input file '#{Kconv.tosjis(inputFile)}' does not exist!"
      end
    end

    attr_reader :log
    attr_accessor :fileTitle, :fileBody, :outputName
  end  # Reader Class
end

