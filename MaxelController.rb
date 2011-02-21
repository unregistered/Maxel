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
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details

class MaxelController
  attr_accessor :window, :downloadURL, :outputTextField, :maxConnections, :targetDirectory
  
  def help(sender)
    self.log("Maxel version 0.1\nEnter the url of a file and click download. Increasing the connections will usually increase the download speed.\n\nYou can get the command line version of Axel at http://axel.alioth.debian.org/\n\n")
  end
  def startDownload(sender)
    #Check for presence
    if(@downloadURL.stringValue == '')
      self.log('Enter a URL to download.')
      return
    end

    self.log("axel -n #{@maxConnections.stringValue} #{@downloadURL.stringValue}")
    
    @Downloader = MaxelDownloader.new(self, {
      :outputDir => @targetDirectory.stringValue.stringByExpandingTildeInPath.stringByStandardizingPath,
      :connections  => @maxConnections.stringValue,
      :url  => @downloadURL.stringValue
    })
    
    @Downloader.run.register
  end
  def awakeFromNib
    @outputTextField.setEditable(false)
    @targetDirectory.setStringValue('~/Downloads'.stringByExpandingTildeInPath)
  end
  
  def log(string)
    @outputTextField.setString(string + "\n" + @outputTextField.string)
  end
end