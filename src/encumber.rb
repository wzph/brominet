require 'enumerator' 
require 'net/http'
require 'tagz'
require 'nokogiri'

module Net
  class HTTP
    def self.post_quick(url, body)
      url = URI.parse url
      req = Net::HTTP::Post.new url.path
      req.body = body

      http = Net::HTTP.new(url.host, url.port)

      res = http.start do |sess|
        sess.request req
      end

      res.body
    end
  end
end

module Encumber

  class XcodeProject
    def initialize path_for_xcode_project
      @project        = path_for_xcode_project
    end

    def set_target_for_simulator_debug name
      
      set_target({
                   :name         => name,
                   :config       => 'Debug',
                   :sdk          => 'iphonesimulator3.0',
                   :path_for_sdk => '/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator3.0.sdk/'
                 })
    end


    def set_target opt

      @name_for_target    = opt[:name]
      @configuration_type = opt[:config]
      @sdk                = opt[:sdk]
      @path_for_sdk       = opt[:path_for_sdk]

      %x{osascript<<APPLESCRIPT
tell application "Xcode"
  set myProject to active project document
  tell myProject
    set the active target to the target named "#{@name_for_target}"
    set active build configuration type to build configuration type "#{@configuration_type}"
    set active SDK to "#{@sdk}"
    set value of build setting "SDKROOT" of build configuration "#{@configuration_type}" of active target to "#{@path_for_sdk}"
  end tell
end tell
APPLESCRIPT
 2>&1}
    end

    def set_target_for_brominet
      set_target_for_simulator_debug 'Brominet'
    end


    def start
      %x{open #{@project}}
    end

    # This is a universal quit method, that leverages AppleScript to
    # close any arbitrary application.

    def quit name_for_app
      status_for_quit = %x{osascript<<APPLESCRIPT
tell application "#{name_for_app}"
  quit
end tell
APPLESCRIPT
 2>&1}

      sleep 7

      status_for_quit

    end

    def quit_all
      quit_simulator
      quit_xcode
    end

    def quit_xcode
      quit "Xcode"
    end

    def quit_simulator
      quit "iPhone Simulator"
    end

    # Attempt to launch whichever build target is selected.

    def launch_app_in_simulator
      status_for_launch = %x{osascript<<APPLESCRIPT
tell application "Xcode"
  set myProject to active project document
  launch the active executable of myProject
end tell
APPLESCRIPT
 2>&1}

      sleep 7 unless status_for_launch =~ /Unable to launch executable./

      status_for_launch

    end


    # Reset the iPhone simulator, removing all installed apps and
    # settings.  Great for teardowns.
    #
    # IMPORTANT: the elipsis in the Reset menu item name, is NOT three
    # dots.  It is a special Mac character: "…"

    def reset_simulator
      status_for_delete = %x{osascript<<APPLESCRIPT
activate application "iPhone Simulator"

tell application "System Events"
    click menu item "Reset Content and Settings…" of menu "iPhone Simulator" of menu bar of process "iPhone Simulator"

    tell process "iPhone Simulator"
            tell window 1
                    click button 2
            end tell
    end tell
end tell
APPLESCRIPT
 2>&1}

      status_for_delete

    end

  end

  class GUI
    def initialize(host='localhost', port=50000, timeout_in_seconds=4)
      @host, @port = host, port
      @timeout     = timeout_in_seconds
    end

    def command(name, *params)
      raw = params.shift if params.first == :raw
      command = Tagz.tagz do
        plist_(:version => 1.0) do
          dict_ do
            key_ 'command'
            string_ name
            params.each_cons(2) do |k, v|
              key_ k
              raw ? tagz.concat(v) : string_(v)
            end
          end
        end
      end

      Net::HTTP.post_quick \
      "http://#{@host}:#{@port}/", command
    end

    def restart
      begin
        @gui.quit
      rescue EOFError
        # no-op
      end

      sleep 3

      yield if block_given?

      launch

    end

    def quit
      command 'terminateApp'
    end

    def dump
      command 'outputView'
    end

    def press(xpath)
      command 'simulateTouch', 'viewXPath', xpath
    end

    # Nokogiri XML DOM for the current Brominet XML representation of the GUI
    def dom_for_gui
      @dom = Nokogiri::XML self.dump
    end

    # Idiomatic way to say wait_for_element

    def wait_for xpath
      wait_for_element xpath
    end

    # Wait for element.  Returns an array of elements that match the
    # xpath, or nil if nothing matches the xpath and the timeout
    # period has expired.
    # 
    # Note that there's no need to sleep between polls.  At most, we
    # can only poll about every other second, because it takes that
    # long to request and receive the Brominet GUI XML.

    def wait_for_element xpath
      start_time_for_wait = Time.now

      loop do
        elements                = dom_for_gui.search(xpath)

        return elements unless elements.empty?

        # Important: get the elapsed time AFTER getting the gui and
        # evaluating the xpath.
        elapsed_time_in_seconds = Time.now - start_time_for_wait

        return nil if elapsed_time_in_seconds >= @timeout
      end
    end

    def type_in_field text, xpath
      command('setText', 
              'text',      text,
              'viewXPath', xpath)
      sleep 1
    end

    # swipe to the right
    def swipe xpath
      command('simulateSwipe',  
              'viewXPath', xpath)
    end

    # swipe to the left
    def swipe_left xpath
      command('simulateLeftSwipe',  
              'viewXPath', xpath)
    end

    def swipe_and_wait xpath
      swipe xpath
      sleep 1
    end

    def swipe_left_and_wait xpath
      swipe_left xpath
      sleep 1
    end

    def tap xpath
      press xpath
    end

    def tap_and_wait xpath
      press xpath
      sleep 1
    end

  end
end
