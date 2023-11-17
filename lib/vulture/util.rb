# frozen_string_literal: true

require 'yaml'
require 'pry'
module Vulture::Util
  # Set all possible manipulable inputs. Meaning, try to map all user inputs
  # @param [String] in_file File path to be analized.
  # @param [String] lang The The program language of the file.
  # @return [Array, nil] Array for user's input variables.
  def get_manipulable_inputs(file_lines)
    begin
      # binding.pry
      user_input_pattern = syntax['inputs']['static']
      raise "unable to find input user_input_pattern for #{lang}" if syntax['inputs']['static'].nil?

      # inputs = []
      comments = get_comments(file_lines)
      def get_inputs(file_lines, user_input_pattern, comments)
        line_number = 0
        file_lines.each do |line|
          line_number += 1

          next if comments[file].include?(line_number) || line.match("^\n$")

          user_input_pattern.each do |pattern|
            # binding.pry
            line.force_encoding('ISO-8859-1').encode('UTF-8').match(/#{pattern}/i)
            if !Regexp.last_match(1).nil? && Regexp.last_match(1).length > 2 # para evitar alguns falso positivos so pegamos variaveis maiores que 2
              tmpVar = Regexp.last_match(1)
              # if tmpVar.match(/^\$/) # remove o caracter "$" do nome da variavel para ficar generico
              tmpVar.gsub!(/^\$/, '').strip! if tmpVar&.match(/^\$/)
              # end
              inputs << "\\$?#{tmpVar}" # adiciona novamente o "$" entretanto agora ele eh opcional
            end
          end
        end
        return inputs.uniq
      end
      inputs = get_inputs(file_lines, syntax['inputs']['static'], comments)
      # generate dynamic pattern for manipulable inputs
      # 
      user_input_pattern2 = generate_dynamic_patterns(syntax['inputs']['dynamic'], inputs.uniq)
      puts user_input_pattern2
      inputs = (inputs + get_inputs(file_lines, user_input_pattern2, comments)).uniq

      user_input_pattern3 = generate_dynamic_patterns(syntax['inputs']['dynamic'], inputs.uniq)
      inputs = (inputs + get_inputs(file_lines, user_input_pattern3, comments)).uniq
      # file_lines = nil
      raise RuntimeError.new('Unable to find manipulable input') if inputs.nil? || inputs.empty?
    rescue Exception, RuntimeError => e
      raise e.message
    end
    return inputs.uniq!
  end

  # Get rotscan pattern
  # @param [String] rot The vulnerability category.
  # @return [Array] Array of Regexp that match vulnerable pattern.
  def get_patterns(rot)
    yml = "#{Vulture::RootInstall}/signatures/#{rot}.yml"
    if File.file?(yml)
      pattern = YAML.load_file(yml)[lang]
      if pattern.nil?
        raise "patterns were not found to #{rot}!"
      else
        pattern
      end
    else
      raise "file #{yml} not found!"
    end
  rescue RuntimeError => e
    raise e.message
  end

  # Anexa o nome das variaveis no pattern lido do conf/*.yml
  # @param [Array] input_pattern An array of Regexp to be match against the file
  # @param [Array] user_inputs An array of variables mapped (see #get_manipulable_inputs)
  # @return [Array]
  def generate_dynamic_patterns(input_pattern, user_inputs)
    return nil if input_pattern.nil? || user_inputs.nil?

    # função para remover o ")" do final da linha
    def splitbracket(s)
      case s
      when /(\)\\\))$/ # match ")\)" end of line
        ret = s.gsub(/(\)\\\))$/, '')
        replaced = 1
        [ret, replaced]
      when /\)\\\)\?$/ # match ")\)?" end of line
        ret = s.gsub(/\)\\\)\?$/, '')
        replaced = 2
        [ret, replaced]
      when /(\\\))$/ # match '\)' end of line
        ret = s.gsub(/(\\\))$/, '')
        replaced = 3
        [ret, replaced]
      when /(\))$/ # match simple ')' end of line
        ret = s.gsub(/(\))$/, '')
        replaced = 4
        [ret, replaced]
      else
        replaced = 0
        [s, replaced]
      end
    end

    var_pattern = []
    user_inputs.each do |var|
      v = var.gsub(']', '\]')
      v = var.gsub('+', '\+')
      v = var.gsub(')', '')
      v = var.gsub('(', '')
      if var_pattern.empty?
        var_pattern << v.to_s
      else
        unless var_pattern.include?(v)
          var_pattern << "|#{v}"
        end
      end
    end

    # ret = []
    macro_pattern, ret = input_pattern.partition { |pattern| pattern.match(/\(.+\).*\((MARK)\)/) }
    macro_pattern.each do |p|
      # pattern.match(%r{.*\(.*\).*\((.*)\).+})
      # another magic
      p.match(/\(.+\).*\((MARK)\)/).captures
      ret << p.gsub(Regexp.last_match(1), var_pattern.uniq.join)
      pattern, replaced = splitbracket(pattern.to_s)
      ret << case replaced
             when 1
               "#{pattern})\\)" # add ')/)'
             when 2
               "#{pattern})\\)?" # ')/)?'
             when 3
               "#{pattern}\\)" # /)
             when 4
               "#{pattern})" # )
             else
               pattern.to_s
             end
    end

    ret.reject!(&:empty?) # cleanup
    ret
  end

  # Get files in a directory by extension
  # @param [String] dir Directory of the project to be analized.
  # @patam [String] lang  The program language of the project.
  # @return [Array] List of files.
  def get_files(dir)
    # msg = Msg.new()
    if lang.nil? || lang.empty? || (lang == '')
      return nil
    elsif dir.nil? || dir.empty? || (dir == '')
      return nil
    end
    raise 'is not a valid directory' unless File.directory?(dir)

    ext = ".#{lang}"
    # lib_files = File.join(File.expand_path(dir), "**", "*#{ext}")
    lib_files = File.join(dir, '**', "*#{ext}")
    # Vulture::Output.print_debug("::#{__method__}::MSG::Obj::#{lib_files.inspect}")

    files = Dir.glob(lib_files)
    if files.nil? || files.empty?
      raise "no files \"#{lang}\" founds"
      # return nil
    else
      files.uniq
    end
  rescue Exception => e
    raise e.message
  end

  # Get the line number that has a comment
  # @param [String] lang The language to look for comments.
  # @param [String] file The file path to look.
  # @return [Array] List of line with comments.
  def get_comments(file_lines)
    comments_pattern = syntax['comments']

    comment_lines = {}
    comment_lines[file] = []
    is_comment = false
    line_number = 0

    return comment_lines if comments_pattern.nil? # return empty arrray if not comment syntax defined

    file_lines.each do |line|
      is_comment = false
      line_number += 1
      comments_pattern.each do |com|
        is_comment = true if line.strip.match(/#{com}/)
      end
      comment_lines[file] << line_number if is_comment
    end

    comment_lines
  end
end
