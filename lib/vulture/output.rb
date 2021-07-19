# frozen_string_literal: true

require 'pry'
module Vulture::Output
  def colorize(text, color_code)
    "\e[#{color_code}m#{text}\e[0m"
  end

  def red(text)
    colorize(text, 31)
  end

  def green(text)
    colorize(text, 32)
  end

  def blue(text)
    colorize(text, 34)
  end

  def print_debug(s)
    print_info("::#{__method__}::\s#{s}") if debug
  end

  def print_verbose(s)
    print_info("::#{__method__}::\s#{s}") if verbose
  end

  def print_info(s)
    print("\s#{blue('[*]')}\t#{s}\n")
    nil
  end

  def print_error(s)
    raise s
  rescue Exception => e
    print("\s#{red('[-]')}\t#{e.message}\n")
    print("\s#{red('[-]')}\t#{e.backtrace.join("\n")}\n") if debug
    exit 1
  end

  def print_good(s)
    if s.is_a?(Array)
      s.each do |a|
        print_good(a)
      end
    else
      print("\s#{green('[+]')}\t#{s}")
      nil
    end
  end

  def report(founds)
    return nil if founds.nil?

    msg = []
    # FIX This
    # {:filename=>"files_test/cmd.php", :rot=>"rce", :matched=>["popen", "$sendmail"], :line_number=>10}

    founds.each do |a|
      msg << "Possible:\s#{rot}\s#{a[:matched]} in file #{file} line: #{a[:line_number]}\n"
    end

    msg.uniq!

    if outfile.nil?
      print_good(msg)
    else
      writeout(outfile, msg)
      nil
    end
  end

  private

  def writeout(file, msg)
    outFile = File.open(file, File::WRONLY | File::APPEND | File::CREAT)
    outFile.puts(print_good(msg))
    outFile.close
  rescue Exception => e
    print_error(e)
  end
end
