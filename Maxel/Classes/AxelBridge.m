//
//  AxelBridge.m
//  Maxel
//
// Copyright (C) 2011 Chris Li
//
// Maxel is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details

#import "AxelBridge.h"

void print_messages( axel_t *axel )
{
	message_t *m;
	
	while( axel->message )
	{
		NSLog( @"%s\n", axel->message->text );
		m = axel->message;
		axel->message = axel->message->next;
		free( m );
	}
}


@implementation AxelBridge
@synthesize filename, url, directory, connections, conf, axel, status, start_time, next_state, finish_time, bytes_done, start_byte, size, bytes_per_second, delay_time, outfd, ready, message;

-(id) init
{
	NSLog(@"Init");
    self.connections = 1;
	conf_t *myconf = calloc(1, sizeof(conf_t));
    
    conf_init(myconf);

    self.conf = myconf;
    self.axel = NULL;
    
    
    self.start_time = 0;
    self.next_state = 0;
    self.finish_time = 0;
    self.bytes_done = 0;
    self.start_byte = 0;
    self.size = 0;
    self.bytes_per_second = 0;
    self.delay_time = 0;
    self.outfd = 0;
    self.ready = 0;
    //self.message = [[NSMutableString alloc] init];
    //[message setString:@""];
    return self;
}

-(int) start{
    // Set num_connections
    conf->num_connections = connections;
	axel = axel_new( conf, 0, (char*)[url UTF8String] );
    
    if(!axel_open(axel))
    {
        return 0;
    }
    axel_start(axel);
    self.size = axel->size;
    self.start_byte = axel->start_byte;
    return 1;
}
-(int) run{
    
    //while(!axel->ready){
    axel_do(axel);
    start_time = axel->start_time;
    next_state = axel->next_state;
    finish_time = axel->finish_time;
    bytes_done = axel->bytes_done;
    bytes_per_second = axel->bytes_per_second;
    delay_time = axel->delay_time;
    outfd = axel->outfd;
    ready = axel->ready;
    message = @"";
    //message = [[NSString alloc] initWithCString:axel->message->text length:1024];
    print_messages(axel);
    //}

    return 1;
}

-(int) close{
    axel_close(axel);
    return 1;
}
@end
