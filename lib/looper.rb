# Copyright (c) 2008 Zetetic LLC

# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

module Looper
  
  def trap_signals
    sigtrap = proc { 
      puts "caught trapped signal, shutting down"
      @run = false 
    }
    signals = ["SIGTERM", "SIGINT"]
    signals.push("SIGHUP") unless is_windows?
    signals.each do |signal|
      trap signal, sigtrap
    end
  end
  
  def is_windows?
    processor, platform, *rest = RUBY_PLATFORM.split("-")
    platform == 'mswin32'
  end

  def loopme(run_every = 10)
    # we don't want to delay output to sdtout until the program stops, we want feedback!
    $stdout.sync=true
    
    trap_signals
    
    @run = true
    
    puts "#{Time.now} process started with #{run_every} loop. kill #{Process.pid} to stop"
    
    last_run = Time.now - run_every - 1
    while (@run) do
      now = Time.now
      if last_run + run_every < now
        begin
          yield
        rescue Exception => e
          puts "Uncaught exception bubbled up: \n#{e.class}: #{e.message}\n\t#{e.backtrace.join("\n\t")} "
        end
        last_run = now
      end  
      sleep(2)
    end
    puts "#{Time.now} shutting down"
  end
  
  def write_pid(filename, pid)
    file = File.new(filename, "w")
    file.print pid.to_s
    file.close
  end
  
  def exit_loop
    @run = false
  end
end