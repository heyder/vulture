#!/usr/bin/env ruby
# -*- encoding : utf-8 -*-
require_relative 'setup.rb'
#
options = {
  :lang => nil,
  :rot => nil,
  :dir => nil,
  :report => nil,
  :debug => false,
  :verbose => false
#  :url => nil,
#  :proxy_addr => "127.0.0.1",
#  :proxy_port => 8080,
#  :use_proxy  => true
}
#
OptionParser.new do |opts|
  begin
    opts.banner = "Usage: main.rb -l LANG -d DIR"
    opts.on("-l", "--lang LANG", "Language files") do |h|
      options[:lang] = h
    end
    opts.on("-c", "--category VULN", "Check for ? e.g.: xss [default: all]") do |e|
      options[:rot] = e
    end
    opts.on("-p", "--path ", "Path to project source code files that should be analysed") do |y|
      options[:dir] = y
    end
    opts.on("-r", "--report PATH", String, "Specify the report output file") do |d|
      options[:report] = d
    end
    opts.on("-v", "--verbose", "Verbose output") do |e|
      options[:verbose] = true
    end
    opts.on("-d", "--debug", "Running in debug mode") do |r|
      options[:debug] = true
    end
    opts.parse!
    if (options[:lang].nil? or options[:dir].nil?)
      raise 'Language and project path are required'
    end
    rescue Exception => e
      puts "[ERROR]\s#{e.message}"
      exit 1
  end
end
#

v = [:debug, :verbose].inject({}) {|h,k| h[k] = options.delete(k) if options.key?(k);h}

DEBUG   ||= v[:debug]
VERBOSE ||= v[:verbose]

Dir["#{RootInstall}/modules/*.rb"].each {|file| require_relative file }

Msg.new().debug("::#{__method__}::MSG::Options#{options.inspect}")
#  
def main(options)

  msg           = Msg.new()
  vulture       = RotScanner.new(options)

  msg.debug("::#{__method__}::MSG::Vulture#{vulture.inspect}")
  #TODO - file_path_validator
  msg.info("The report file will be saved in #{vulture.report}") if vulture.report
  
  vFiles = getFiles(vulture.dir,vulture.lang)
	  
  vFiles.each do |file|
    inputs = get_manipulable_inputs(file,vulture.lang)
    vulture.vars = vulture.vars | inputs unless inputs.nil?
  end
  msg.debug("::#{__method__}::MSG::Vulture:vars#{vulture.vars}")
  

  if (vulture.rot.nil?)
    # run all valide search for something wrong in the source code
    VALID_ROTS.each do |rot|
	    vulture.rot = rot
      run(vFiles,vulture)
    end
  else
    run(vFiles,vulture)
  end
  
end
#
def run(pFiles,vulture)

  msg               = Msg.new()
  vulture.patterns  = GetPatterns(vulture.rot,vulture.lang) # get regex for vulnerability category
  if (vulture.rot != 'misc')
    unless (vulture.vars.empty?)
      # the magic happens here
      # the jump of the cat :)
      vulture.patterns = generate_dynamic_patterns( vulture.patterns, vulture.vars )  # anexa a os inputs manipulavei nos padros pre estabelecido
    end 
  end
  msg.debug("::RotScanner::#{__method__}::MSG::[@patterns]\t#{vulture.patterns.inspect}" )

  pFiles.each do |file|

    vulture.file  = file
	  founds        = vulture.to_analyze()
    #unless (founds.nil?)
    #msg.found(vulture.rot,founds,vulture.report)
    msg.report(vulture,founds)
    #end

  end

  vulture.patterns  = nil

end

main(options)
