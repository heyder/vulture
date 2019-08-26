
require 'pry'
module Vulture::Output 

  def colorize(text, color_code)
    "\e[#{color_code}m#{text}\e[0m"
  end

  def red(text); colorize(text, 31); end
  def green(text); colorize(text, 32); end
  def blue(text); colorize(text, 34); end

  def debug(s)
    self.info("::#{__method__}::\s#{s}") if Vulture::DEBUG
  end

  def info(s)
    print("\s#{blue('[*]')}\t#{s}\n")
    return nil
  end 

  def erro(s)
    raise s
    rescue Exception => error
      print("\s#{red('[-]')}\t#{error.message}\n")
      print("\s#{red('[-]')}\t#{error.backtrace.join("\n")}\n") if Vulture::DEBUG
      exit 1
  end 
  
  def good(s)
  	if (s.kind_of?(Array))
	    s.each do |a|
	      self.good(a)
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
	    self.good(msg)
	  else
	    writeout(self.outfile,msg)
      return nil
	  end

  end 

  private
  def writeout(file,msg)
	  
    begin
      outFile = File.open(file, File::WRONLY|File::APPEND|File::CREAT) 
      outFile.puts(good(msg))
      outFile.close
	  rescue Exception => e
	    erro(e)
    end
  end


end
