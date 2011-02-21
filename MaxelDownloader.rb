# MaxelDownloader.rb
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

class MaxelDownloader
  attr_reader :inProgress
  def initialize(controller, params)
    @controller = controller
    @inProgress = false
    @task = NSTask.new
    @task.setLaunchPath(NSBundle.mainBundle.pathForAuxiliaryExecutable('axel'))
    @task.setCurrentDirectoryPath(params[:outputDir])
    @task.setArguments(["-n #{params[:connections]}", params[:url]])

    @pipe = NSPipe.new

    @task.setStandardOutput(@pipe)
    @task.setStandardError(@pipe)
    #@pipe
    @task.standardOutput.fileHandleForReading.readInBackgroundAndNotify
    
    self
  end
  
  def run
    @task.launch
    @inProgress = true
    self
  end
  
  def kill
    @task.terminate
    NSNotificationCenter.defaultCenter.removeObserver(self, name: NSFileHandleReadCompletionNotification, object: nil)
    @controller.log('Finished!')
    @inProgress = false
    self
  end
  
  def register
    NSNotificationCenter.defaultCenter.addObserver(self, selector: :"outputRecieved:", name: NSFileHandleReadCompletionNotification, object: nil)
    
  end
  
  def outputRecieved(notification)
    data = notification.userInfo.objectForKey(NSFileHandleNotificationDataItem)
    if(data.length > 0)
      string = NSString.alloc.initWithData data, encoding: NSUTF8StringEncoding
      #Attempt to extract info
      fragments = string.scan(/\[(.*)\]/)
      @controller.log(fragments.join('     ')) if(fragments.size == 2)
      notification.object.readInBackgroundAndNotify
    else
      self.kill
    end
  end
  
end