# configure IRB for debugging Brominet instances

# NOTE on Mac Leopard and higher, enable Control-r (reverse history
# search) by creating a ~/.editrc file, see gist.github.com/324413
IRB.conf[:IRB_NAME] = 'iPhone'

IRB.conf[:SAVE_HISTORY] = 10 * 1000
IRB.conf[:HISTORY_FILE] = ".irb_history"

#  standard libraries
require 'rubygems'
IRB.conf[:LOAD_MODULES] += ['nokogiri', 'yaml']

#  Encumber, the Ruby adapter for Brominet
IRB.conf[:LOAD_MODULES] += ['other_src/justplayed/lib/encumber']


# run arbitrary AppleScript fragment
def apple script
  puts %x{osascript<<APPLESCRIPT
#{script}
APPLESCRIPT
 2>&1}
end

# New Encumber instance, using the IP or host name of an iPhone
# running Brominet.  Port 50000 will be used automatically, so you
# just need to supply 1 argument: the host name or IP.
def spawn host
  @gui = Encumber::GUI.new host
end

# Nokogiri XML DOM for the current Brominet XML representation of the GUI
def dom
  @dom = Nokogiri::XML @gui.dump
end

# write the current Encumber/iPhone GUI XML representation, to a file
def dump
  File.open('encumber_gui.xml', 'w') {|f| f.write(@gui.dump) }
end

# disable echoing the results of evaluated expressions
def quiet
  irb_context.echo = false
end

# enable echoing evaluation results
def loud
  irb_context.echo = true
end
