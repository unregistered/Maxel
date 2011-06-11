#
#  utility.rb
#  Maxel
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

def human_readable_size(bytes)
    
    return sprintf("%d bytes", bytes) if bytes < 1023
    bytes = bytes/1024.0
    
    return sprintf("%0.2f KB", bytes) if bytes < 1023
    bytes = bytes/1024.0
    
    return sprintf("%0.2f MB", bytes) if bytes < 1023
    bytes = bytes/1024.0
    
    return sprintf("%0.2f GB", bytes)
end