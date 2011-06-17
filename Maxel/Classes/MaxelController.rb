# MaxelController.rb
# Maxel
#
# Copyright (C) 2011 Chris Li
#
# Maxel is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details

require 'pathname'

class MaxelController
    attr_accessor :window, :downloadURL, :inputTextField, :maxConnections, :targetDirectory, :progressBar, :loggingTextField, :downloadButton
        
    attr_accessor :done, :size, :speed, :name
    
    attr_accessor :window, :mainWindow
            
    def help(sender)
        log("Maxel version 1.2\nEnter the url of a file and click download. Increasing the connections will usually increase the download speed.\n\nYou can get the command line version of Axel at http://axel.alioth.debian.org/\n\n")
    end
        
    def multiDownload sender
        downloads = @inputTextField.string.split("\n")
        
        if downloads.empty?
            log 'Enter URLs to download, one per line'
            return
        end
        
        @downloadButton.setEnabled false

        
        set_download_path

        gcd = Dispatch::Queue.new('com.unregistered.maxel')
        downloads.each_with_index do |url, index|
            gcd.async do
                a = AxelBridge.new
                a.url = url
                a.connections = @maxConnections.stringValue
                
                
                log "Starting #{url}", true
                a.start 
                Dispatch::Queue.main.sync do
                    @name.setStringValue Pathname.new(url.stringByReplacingPercentEscapesUsingEncoding 4).basename
                    @size.setStringValue human_readable_size(a.size)
                end
                
                until a.ready != 0
                    a.run
                    Dispatch::Queue.main.sync do
                        @progressBar.setDoubleValue 100*a.bytes_done/a.size
                        @done.setStringValue human_readable_size(a.bytes_done)
                        @speed.setStringValue "#{human_readable_size(a.bytes_per_second)}/s"
                    end
                end
                a.close
                log "Finished.", true
                
                if index == downloads.length - 1
                    Dispatch::Queue.main.sync do
                        log "Downloads Complete"
                        NSSound.soundNamed('Glass').play
                        @name.setStringValue "Idle"
                        @speed.setStringValue "---"
                        @downloadButton.setEnabled true
                        @targetDirectory.setStringValue('~/Downloads'.stringByExpandingTildeInPath)
                    end
                end
            end
        end
        
    end
    
    # Deal with opened files
    def application sender, openFile: filename
        open_metalink filename
        return true
    end
    def open_metalink filename
        # Show the window if it's closed
        window.makeKeyAndOrderFront self

        log "Opening metalink #{filename}"
        require 'rexml/document'
        file = Pathname.new(filename)
        m4 = REXML::Document.new file.read
        
        m4.elements.each('metalink/file/url') do |e|
            @inputTextField.setString e.text+"\n"+@inputTextField.string
        end
        
        # Guess the first directory name
        f = Pathname.new m4.elements.to_a('metalink/file').first.attributes['name']
        if f.parent != Pathname.new('.')
            @targetDirectory.setStringValue (Pathname.new(@targetDirectory.stringValue) + f.parent.to_s).to_s
        end
    end
    
    # Come back from closed
    def applicationShouldHandleReopen aNotification, hasVisibleWindows: flag
        window.makeKeyAndOrderFront self
        return true
    end
    
    def awakeFromNib
        @loggingTextField.setEditable(false).setString "Welcome to Maxel. Enter URLs in the text field to the left, one per line."
        @targetDirectory.setStringValue('~/Downloads'.stringByExpandingTildeInPath)
        @progressBar.setIndeterminate false
    end
    
    def set_download_path
        Pathname.new(@targetDirectory.stringValue).mkpath
        NSFileManager.defaultManager.changeCurrentDirectoryPath(@targetDirectory.stringValue.stringByExpandingTildeInPath.stringByStandardizingPath)
    end
    
    def log(string, async=false)
        if async
            Dispatch::Queue.main.sync do
                @loggingTextField.setString(string + "\n\n" + @loggingTextField.string)
            end
        else
            @loggingTextField.setString string + "\n\n" + @loggingTextField.string
        end
    end
end