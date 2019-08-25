
class RotScanner

	attr_accessor :lang, :rot, :dir, :report, :patterns, :file, :vars
	VALID_ROTS = ['injection','file_inclusion','rce','misc']

	def initialize(opts={})

		opts.each do |k,v|
			instance_variable_set("@#{k}", v) unless v.nil?
		end 
		unless (VALID_ROTS.include?(@rot) or @rot.nil?)
			raise RuntimeError.new( 'Invalid rotscan!' )
		#   Msg.new().erro("Invalid rotscan!")
		end

		@patterns = nil
		@vars = []

	end
  

	# start function
	def to_analyze()
		begin
			msg =  Msg.new()

			instance_variables.each do |variable|
				v = instance_variable_get( variable )
				msg.error("Required field [#{variable}] is #{v.inspect}. Unable to analyze project!") if ( v.nil? ) 
			end 

			msg.info( "::MSG::analyzing...\s#{@file}\sagainst\s\"#{@rot}\"\spatterns" ) if (VERBOSE)

			source_code_fd = File.open(@file)

			nLine = 0
			founds = []
		
			source_code_fd.each do |line|
				nLine += 1
				# TODO - to ignore comments' line
				@patterns.each do |pattern|
					ret = line.force_encoding("ISO-8859-1").encode("UTF-8").match(%r{#{pattern}}i)
					unless (ret.nil?)
						msg.debug("::RotScanner::#{__method__}::MSG::[MATCHED]\t#{ret.captures.to_a}" )                        
						founds << {:matched => ret.captures.to_a, :line_number => nLine}
						end
					end
			end

			source_code_fd.close

			if (founds.empty? || founds.nil?)
				return nil
			else
				return nil if !founds.first.has_key?(:matched)
				founds.uniq!
				return founds
			end
		rescue Exception => e
			msg.erro(e)
		end
	end

end 


