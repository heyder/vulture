#!/usr/bin/env ruby
# frozen_string_literal: true

# require 'yaml'
require 'optparse'
require 'bundler/setup'
require 'vulture'
options = {
  lang: nil,
  rot: nil,
  dir: nil,
  outfile: nil,
  debug: false,
  verbose: false
}

OptionParser.new do |opts|
  begin
    opts.banner = 'Usage: main.rb -l LANG -d DIR'
    opts.on('-l', '--lang LANG', 'Language files') do |h|
      options[:lang] = h
    end
    opts.on('-c', '--category VULN', 'Check for ? e.g.: xss [default: all]') do |e|
      options[:rot] = e
    end
    opts.on('-p', '--path ', 'Path to project source code files that should be analysed') do |y|
      options[:dir] = y
    end
    opts.on('-o', '--outfile PATH', String, 'Specify the report output file') do |d|
      options[:outfile] = d
    end
    opts.on('-v', '--verbose', 'Verbose output') do |_e|
      options[:verbose] = true
    end
    opts.on('-d', '--debug', 'Running in print_debug mode') do |_r|
      options[:debug] = true
    end
    opts.parse!
    if options[:lang].nil? || options[:dir].nil?
      raise 'Language and project path are required'
    end
  rescue Exception => e
    puts "[ERROR]\s#{e.message}"
    exit 1
  end
  opts.on('-o', '--outfile PATH', String, 'Specify the report output file') do |d|
    options[:outfile] = d
  end
  opts.on('-v', '--verbose', 'Verbose output') do |_e|
    options[:verbose] = true
  end
  opts.on('-d', '--print_debug', 'Running in print_debug mode') do |_r|
    options[:debug] = true
  end
  opts.parse!
  if options[:lang].nil? || options[:dir].nil?
    raise 'Language and project path are required'
  end
rescue Exception => e
  puts "[ERROR]\s#{e.message}"
  exit 1
end
puts options.inspect

def main(options)
  vulture = Vulture.new(options)

  # TODO: - file_path_validator
  vulture.print_info("The report file will be saved in #{vulture.outfile}") if vulture.outfile

  files_list = vulture.get_files(vulture.dir)

  vulture.print_debug("::#{__method__}::vulture::files::#{files_list.length}")

  files_list.each do |file|
    fd = File.readlines(file)
    inputs = vulture.get_manipulable_inputs(fd)
    vulture.inputs = vulture.inputs | inputs unless inputs.nil?
    fd = nil
  end
  vulture.print_verbose("::#{__method__}::vulture::inputs::#{vulture.inputs}")

  if vulture.rot.nil?
    # run all valide search for something wrong in the source code
    Vulture::VALID_ROTS.each do |rot|
      vulture.rot = rot
      run(files_list, vulture)
    end
  else
    run(files_list, vulture)
  end
end

def run(pFiles, vulture)
  vulture.patterns = vulture.get_patterns(vulture.rot) # get regex for vulnerability category
  if vulture.rot != 'misc' && !vulture.inputs.empty?
    # the magic happens here
    # the jump of the cat :)
    vulture.patterns = vulture.generate_dynamic_patterns(vulture.patterns, vulture.inputs) # anexa a os inputs manipulavei nos padros pre estabelecido
  end
  vulture.print_debug("::#{__method__}::MSG::[@patterns]\t#{vulture.patterns.inspect}")

  pFiles.each do |file|
    vulture.print_verbose("analyzing...\s#{file}\sagainst\s\"#{vulture.rot}\"\spatterns")
    vulture.file = file
    founds = vulture.to_analyze
    # unless (founds.nil?)
    # vulture.found(vulture.rot,founds,vulture.report)
    vulture.report(founds)
    # end
  end

  vulture.patterns = nil
end

main(options)
