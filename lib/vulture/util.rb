require 'yaml'
require 'pry'
module Vulture::Util
  # Set all possible manipulable inputs. Meaning, try to map all user inputs
  # @param [String] in_file File path to be analized.
  # @param [String] lang The The program language of the file.
  # @return [Array, nil] Array for user's input variables.
  def get_manipulable_inputs (file_lines) 
    begin

      tracker = self.syntax['inputs']
      raise RuntimeError.new("unable to find input tracker for #{lang}") if tracker.nil?

      comments = get_comments(file_lines)
      line_number = 0
      file_lines.each do |line|
        line_number += 1
        # binding.pry
				next if comments[self.file].include?(line_number)
        tracker.each do | pattern|
          line.force_encoding("ISO-8859-1").encode("UTF-8").match(%r{#{pattern}}i)
            unless ($1.nil?)
              if ($1.length > 2) # para evitar alguns falso positivos so pegamos variaveis maiores que 2
                tmpVar = $1
                if (tmpVar.match(%r{^\$})) # remove o caracter "$" do nome da variavel para ficar generico
                  tmpVar.gsub!(%r{^\$},'').strip!
                end
                self.inputs << "\\$?#{tmpVar}" # adiciona novamente o "$" entretanto agora ele eh opcional
              end
            end
        end
      end
      # file_lines = nil
    rescue Exception, RuntimeError => e
      raise e.message
    end
    return self.inputs.uniq! unless (self.inputs.nil? or self.inputs.empty?)
  end

  # Get rotscan pattern
  # @param [String] rot The vulnerability category.
  # @param [String] lang The program languange to analize. 
  # @return [Array] Array of Regexp that match vulnerable pattern.
  def get_patterns(rot)
    begin
    yml = "#{Vulture::RootInstall}/signatures/#{rot}.yml"
    if (File.file?(yml))
      pattern = YAML::load_file(yml)[self.lang]
      if (pattern.nil?)
        raise  "patterns were not found to #{rot}!"
      else
        return pattern
      end
    else
      raise  RuntimeError.new("file #{yml} not found!")
    end
    rescue Exception => e
      # Msg.new.print_errore)
      raise e.message
    end
  end

  # Anexa o nome das variaveis no pattern lido do conf/*.yml
  # @param [Array] input_pattern An array of Regexp to be match against the file
  # @param [Array] user_inputs An array of variables mapped (see #get_manipulable_inputs)
  # @return [Array]
  def generate_dynamic_patterns(input_pattern,user_inputs)
    if (input_pattern.nil? or user_inputs.nil?)
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

    var_pattern = []
    user_inputs.each do |var|
      var.gsub!(']','\]')
      var.gsub!(']','\]')
      var.gsub!('+','\+')
      var.gsub!(')','')
      var.gsub!('(','')
      if (var_pattern.empty?)
          var_pattern << "#{var}"
      else
        unless (var_pattern.include?(var))
          var_pattern << "|#{var}"
        end
      end
    end
    
    #ret = []
    macro_pattern, ret = input_pattern.partition {|pattern| pattern.match(%r{\(.+\).*\((MARK)\)}) }
    macro_pattern.each do |p|
      #pattern.match(%r{.*\(.*\).*\((.*)\).+})
      # another magic
        p.match(%r{\(.+\).*\((MARK)\)}).captures
        ret << p.gsub($1,var_pattern.uniq.join())
        pattern, replaced = splitbracket("#{pattern}")
        case (replaced)
        when 1
          ret << "#{pattern})\\)" # add ')/)'
        when 2
          ret << "#{pattern})\\)?" # ')/)?'
        when 3
          ret << "#{pattern}\\)" # /)
        when 4
          ret << "#{pattern})" #)
        else
          ret << "#{pattern}"
        end
    end
  
    ret.reject! { |c| c.empty? } # cleanup
    return ret

  end


  # Get files in a directory by extension
  # @param [String] dir Directory of the project to be analized.
  # @patam [String] lang  The program language of the project.
  # @return [Array] List of files.
  def get_files(dir)

    begin
      # msg = Msg.new()
      if ((self.lang.nil?) or (self.lang.empty?) or (self.lang == ''))
        return nil
      elsif
        ((dir.nil?) or (dir.empty?) or (dir == ''))
        return nil
      end
      raise RuntimeError.new("is not a valid directory") unless (File::directory?(dir))

      ext = ".#{self.lang}"
      #lib_files = File.join(File.expand_path(dir), "**", "*#{ext}")
      lib_files = File.join(dir, "**", "*#{ext}")
      # Vulture::Output.print_debug("::#{__method__}::MSG::Obj::#{lib_files.inspect}")

      files = Dir.glob(lib_files)
      if (files.nil? or files.empty?)
        raise "no files \"#{self.lang}\" founds"
        #return nil
      else
        return files.uniq
      end
    rescue Exception => e
      raise e.message
    end

  end

  # Get the line number that has a comment
  # @param [String] lang The language to look for comments.
  # @param [String] file The file path to look.
  # @return [Array] List of line with comments.
  def get_comments(file_lines)
  
    comments_pattern = self.syntax['comments']

    comment_lines = {}
    comment_lines[self.file] = []
    is_comment = false
    line_number = 0

    return comment_lines if comments_pattern.nil? # return empty arrray if not comment syntax defined
   
    file_lines.each do |line|
      is_comment = false
      line_number += 1
      comments_pattern.each do |com| 
        is_comment = true if line.strip.match(/#{com}/) 
      end
      comment_lines[self.file] << line_number if is_comment
    end

    return comment_lines

  end


end
