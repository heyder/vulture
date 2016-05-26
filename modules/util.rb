
def rand_text()

  str  = (0...8).map{65.+(rand(25)).chr}.join.chomp
  return str

end

def get_manipulable_inputs (pFile,pLang) 
  begin
    source_code_fd = File.open(pFile)
    tracker = YAML::load_file(RootInstall+"/signatures/input_tracker.yml")[pLang]
	  #Msg.new().debug("::#{__method__}::MSG::[tracker]\s#{tracker.inspect}" )
    vars = []
    source_code_fd.each do |line|
      tracker.each do | pattern|
        line.force_encoding("ISO-8859-1").encode("UTF-8").match(%r{#{pattern}}i)
          unless ($1.nil?)
            if ($1.length > 2) # para evitar alguns falso positivos so pegamos variaveis maiores que 2
              tmpVar = $1
              if (tmpVar.match(%r{^\$})) # remove o caracter "$" do nome da variavel para ficar generico
                tmpVar.gsub!(%r{^\$},'').strip!
              end
              vars << "\\$?#{tmpVar}" # adiciona novamente o "$" entretanto agora ele eh opcional
            end
          end
      end
    end
	source_code_fd.close
	rescue Exception => e
	  Msg.new().erro(e)
	  return nil
	end
  return vars.uniq unless (vars.nil? or vars.empty?)
end

# Anexa o nome das variaveis no pattern lido do conf/*.yml
# inPattern: array
# inVars: array
#
def generate_dynamic_patterns(inPattern,inVars)
  if (inPattern.nil? or inVars.nil?)
  	return nil
  end
  # função para remover o ")" do final da linha
  def splitbracket(s)
    if s.match(%r{(\)\\\))$}) # match ")\)" end of line
      ret = s.gsub(%r{(\)\\\))$},'')
      replaced = 1
      return ret, replaced
    elsif s.match(%r{\)\\\)\?$}) # match ")\)?" end of line
      ret = s.gsub(%r{\)\\\)\?$},'')  
      replaced = 2
      return ret, replaced
    elsif s.match(%r{(\\\))$}) # match '\)' end of line
      ret = s.gsub(%r{(\\\))$},'')
      replaced = 3
      return ret, replaced
    elsif s.match(%r{(\))$})    # match simple ')' end of line
      ret = s.gsub(%r{(\))$},'')
      replaced = 4
      return ret, replaced
    else
      replaced = 0
      return s, replaced
    end
  end

  nVars = []
  inVars.each do |var|
    var.gsub!(']','\]')
    var.gsub!(']','\]')
    var.gsub!('+','\+')
    var.gsub!(')','')
    var.gsub!('(','')
    if (nVars.empty?)
        nVars << "#{var}"
    else
      unless (nVars.include?(var))
        nVars << "|#{var}"
      end
    end
  end
  
  #ret = []
  macro_pattern, ret = inPattern.partition {|pattern| pattern.match(%r{\(.+\).*\((MARK)\)}) }
  macro_pattern.each do |p|
    #pattern.match(%r{.*\(.*\).*\((.*)\).+})
    # another magic
      p.match(%r{\(.+\).*\((MARK)\)}).captures
      ret << p.gsub($1,nVars.uniq.join())
      pattern, replaced = splitbracket("#{pattern}")
      case (replaced)
        when 1
          ret << "#{pattern})\\)" # add ')/)'
        when 2
          ret << "#{pattern})\\)?" # ')/)?'
        when 3
          ret << "#{pattern}\\)" # /)
        when 4
          ret << "#{pattern})" # )
        else
          ret << "#{pattern}"
      end
  end
 
  ret.reject! { |c| c.empty? } # cleanup
  return ret

end


# Get rotscan pattern
def GetPatterns(rot,lang)
  begin
	yml = "#{RootInstall}/signatures/#{rot}.yml"
	if (File.file?(yml))
  	pattern = YAML::load_file(yml)[lang]
		if (pattern.nil?)
		  raise  "patterns were not found to #{rot}!"
		else
		  return pattern
		end
	else
		raise  "file #{yml} not found!"
	end
	rescue Exception => e
	  Msg.new.erro(e)
	  #return nil
	end
end

# Get Files in a directory by extension
# input: directory,language - e.g: ("/tmp/","php")
# return: Array of files
def getFiles(pDir,pLang)

  begin
    msg = Msg.new()
    if ((pLang.nil?) or (pLang.empty?) or (pLang == ''))
      return nil
    elsif
      ((pDir.nil?) or (pDir.empty?) or (pDir == ''))
      return nil
    end
    unless (File::directory?(pDir))
      s = "is not a valid directory"
      msg.erro(s)
      return nil
    end

    ext = ".#{pLang}"
    #libfiles = File.join(File.expand_path(pDir), "**", "*#{ext}")
    libfiles = File.join(pDir, "**", "*#{ext}")
    msg.debug("::#{__method__}::MSG::Obj::#{libfiles.inspect}")

    files = Dir.glob(libfiles)
	  if (files.nil? or files.empty?)
	    raise "no files \"#{pLang}\" founds"
      #return nil
    else
      return files.uniq
    end
  rescue Exception => e
  	msg.erro(e)
  end

end

