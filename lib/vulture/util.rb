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
      tracker = syntax['inputs']
      raise "unable to find input tracker for #{lang}" if tracker.nil?

      # Msg.new().print_debug("::#{__method__}::MSG::[tracker]\s#{tracker.inspect}")
      vars = []
      # comments = ['^\/\/','^\*','^\/\*'] # only PHP do it for other languages
      file_lines.each do |line|
        # comment = false
        # comments.each {|com| comment = true if line.chomp.match(/#{com}/) }
        # next if comment
        tracker.each do |pattern|
          line.force_encoding('ISO-8859-1').encode('UTF-8').match(/#{pattern}/i)
          if !Regexp.last_match(1).nil? && Regexp.last_match(1).length > 2 # para evitar alguns falso positivos so pegamos variaveis maiores que 2
            tmpVar = Regexp.last_match(1)
            if tmpVar.match(/^\$/) # remove o caracter "$" do nome da variavel para ficar generico
              tmpVar.gsub!(/^\$/, '').strip!
            end
            vars << "\\$?#{tmpVar}" # adiciona novamente o "$" entretanto agora ele eh opcional
          end
        end
      end
      # file_lines = nil
    rescue Exception, RuntimeError => e
      raise e.message
    end
    return vars.uniq unless vars.nil? || vars.empty?
  end

  # Get rotscan pattern
  # @param [String] rot The vulnerability category.
  # @param [String] lang The program languange to analize.
  # @return [Array] Array of Regexp that match vulnerable pattern.
  def get_patterns(rot, lang)
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
  rescue Exception => e
    # Msg.new.print_errore)
    raise e.message
  end

  # Anexa o nome das variaveis no pattern lido do conf/*.yml
  # @param [Array] inPattern An array of Regexp to be match against the file
  # @param [Array] in_vars An array of variables mapped (see #get_manipulable_inputs)
  # @return [Array]
  def generate_dynamic_patterns(inPattern, in_vars)
    if inPattern.nil? || in_vars.nil?
      return nil
    end

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

    n_vars = []
    in_vars.each do |var|
      v = var.gsub(']', '\]')
      v = var.gsub('+', '\+')
      v = var.gsub(')', '')
      v = var.gsub('(', '')
      if n_vars.empty?
        n_vars << v.to_s
      else
        unless n_vars.include?(v)
          n_vars << "|#{v}"
        end
      end
    end

    # ret = []
    macro_pattern, ret = inPattern.partition { |pattern| pattern.match(/\(.+\).*\((MARK)\)/) }
    macro_pattern.each do |p|
      # pattern.match(%r{.*\(.*\).*\((.*)\).+})
      # another magic
      p.match(/\(.+\).*\((MARK)\)/).captures
      ret << p.gsub(Regexp.last_match(1), n_vars.uniq.join)
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
  def get_files(dir, lang)
    # msg = Msg.new()
    if lang.nil? || lang.empty? || (lang == '')
      return nil
    elsif dir.nil? || dir.empty? || (dir == '')
      return nil
    end
    unless File.directory?(dir)
      raise 'is not a valid directory'
      # msg.print_errors)
      # return nil
    end

    ext = ".#{lang}"
    # libfiles = File.join(File.expand_path(dir), "**", "*#{ext}")
    libfiles = File.join(dir, '**', "*#{ext}")
    # Vulture::Output.print_debug("::#{__method__}::MSG::Obj::#{libfiles.inspect}")

    files = Dir.glob(libfiles)
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
