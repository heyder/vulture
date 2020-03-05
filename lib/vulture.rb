
require_relative 'vulture/version'

Dir[File.join(__dir__, 'vulture', '*.rb')].each { |file| require file }

class Vulture

	include Vulture::Util
	include Vulture::Output

	attr_accessor :lang, :rot, :dir, :outfile, :patterns, :file, :inputs
	attr_reader :syntax, :debug, :verbose
	RootInstall = File.expand_path(File.dirname(__FILE__))
	VALID_ROTS = ['injection','file_inclusion','rce','misc']

	def initialize(opts={})

		opts.each do |k,v|
			instance_variable_set("@#{k}", v) unless v.nil?
		end 

		raise RuntimeError.new("lang is required.") unless @lang

		unless (VALID_ROTS.include?(@rot) or @rot.nil?)
			raise RuntimeError.new('Invalid rotscan!')
		end

		@syntax = YAML::load_file(Vulture::RootInstall+"/signatures/syntax.yml")[@lang]

		@patterns = @inputs = []

	end

	def to_analyze()
		begin

			instance_variables.each do |variable|
				v = instance_variable_get(variable)
				print_error("Required field [#{variable}] is #{v.inspect}. Unable to analyze project!") if (v.nil?) 
			end 

			file_lines = File.readlines(@file)
			comments = self.get_comments(file_lines)
			line_number = 0
			founds = []
			
			file_lines.each do |line|
				line_number += 1
				next if comments[@file].include?(line_number)
				self.patterns.each do |pattern|
					ret = line.force_encoding("ISO-8859-1").encode("UTF-8").match(%r{#{pattern}})
					# ret = line.force_encoding("ISO-8859-1").encode("UTF-8").match(%r{#{pattern}}i)
					unless (ret.nil?)
						print_debug("::vulture::#{__method__}::[FOUND]\t#{ret.captures.to_a}")                        
						founds << {:matched => ret.captures.to_a, :line_number => line_number}
					end
				end
			end

			file_lines = nil

			# if (founds.empty? )#|| founds.nil?)
			# 	return nil
			# else
			# 	# return nil if !founds.first.has_key?(:matched)
			# 	founds.uniq!
			# 	return founds
			# end
			return founds unless founds.empty?
		rescue Exception => e
			print_error(e)
		end
	end

end 


