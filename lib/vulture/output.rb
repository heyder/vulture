
require 'pry'
module Vulture::Output 

  def colorize(text, color_code)
    "\e[#{color_code}m#{text}\e[0m"
  end

  def red(text); colorize(text, 31); end
  def green(text); colorize(text, 32); end
  def blue(text); colorize(text, 34); end

  def print_debug(s)
    self.print_info("::#{__method__}::\s#{s}") if self.debug
  end

  def print_verbose(s)
    self.print_info("::#{__method__}::\s#{s}") if self.verbose
  end


  def print_info(s)
    print("\s#{blue('[*]')}\t#{s}\n")
    return nil
  end 

  def print_error(s)
    raise s
    rescue Exception => error
      print("\s#{red('[-]')}\t#{error.message}\n")
      print("\s#{red('[-]')}\t#{error.backtrace.join("\n")}\n") if self.debug
      exit 1
  end 
  
  def print_good(s)
  	if (s.kind_of?(Array))
	    s.each do |a|
	      self.print_good(a)
	    end
	  else
      print("\s#{green('[+]')}\t#{s}")
	    return nil
	  end
  end


  def report(founds)
    return nil if founds.nil?
  
	  msg = []
    # FIX This
    # {:filename=>"files_test/cmd.php", :rot=>"rce", :matched=>["popen", "$sendmail"], :line_number=>10}

    founds.each do |a|
      msg << "Possible:\s#{self.rot}\s#{a[:matched]} in file #{self.file} line: #{a[:line_number]}\n"
    end

    msg.uniq!

    if (self.outfile.nil?)
	    self.print_good(msg)
	  else
	    writeout(self.outfile,msg)
      return nil
	  end

  end 

  private
  def writeout(file,msg)
	  
    begin
      outFile = File.open(file, File::WRONLY|File::APPEND|File::CREAT) 
      outFile.puts(print_good(msg))
      outFile.close
	  rescue Exception => e
	    print_error(e)
    end
  end


end
