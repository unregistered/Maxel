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
    attr_accessor :window, :downloadURL, :inputTextField, :maxConnections, :targetDirectory, :progressBar, :loggingTextField
    
    attr_accessor :done, :size, :speed, :name
        
    def help(sender)
        self.log("Maxel version 0.2\nEnter the url of a file and click download. Increasing the connections will usually increase the download speed.\n\nYou can get the command line version of Axel at http://axel.alioth.debian.org/\n\n")
    end
    def startDownload(sender)
        #Check for presence
        if(@downloadURL.stringValue == '')
            self.log('Enter a URL to download.')
            return
        end
        
        puts ("axel -n #{@maxConnections.stringValue} #{@downloadURL.stringValue}")
        
        set_download_path

        gcd = Dispatch::Queue.new('com.unregistered.maxel')
        gcd.async do
            a = AxelBridge.new
            a.url = @downloadURL.stringValue
            a.connections = @maxConnections.stringValue

            
            puts "Starting"
            a.start 
            
            Dispatch::Queue.main.sync do
                @name.setStringValue Pathname.new(@downloadURL.stringValue.stringByReplacingPercentEscapesUsingEncoding 4).basename
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
            puts "Complete"
        end
    end
    
    def multiDownload sender
        downloads = @inputTextField.string.split("\n")
        
        set_download_path

        gcd = Dispatch::Queue.new('com.unregistered.maxel')
        downloads.each do |url|
            gcd.async do
                log "Doing something"
                a = AxelBridge.new
                a.url = url
                a.connections = @maxConnections.stringValue
                
                
                log "Starting #{url}"
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
                log "Finished."
            end
        end
        
    end
    
    def awakeFromNib
        #@loggingTextField.setEditable(false)
        @targetDirectory.setStringValue('~/Downloads'.stringByExpandingTildeInPath)
        @progressBar.setIndeterminate false
    end
    
    def set_download_path
        Pathname.new(@targetDirectory.stringValue).mkpath
        NSFileManager.defaultManager.changeCurrentDirectoryPath(@targetDirectory.stringValue.stringByExpandingTildeInPath.stringByStandardizingPath)
    end
    
    def log(string)
        Dispatch::Queue.main.sync do
            @loggingTextField.setString(string + "\n" + @loggingTextField.string)
        end
    end
end