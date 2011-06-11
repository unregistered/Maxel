//
//  AxelBridge.h
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

#import <Cocoa/Cocoa.h>
#include "axel.h"


@interface AxelBridge : NSObject {
	NSString *filename;
	NSString *directory;
	NSString *url;
	int connections;
	conf_t *conf;
	axel_t *axel;
    NSMutableDictionary *status;
    double start_time;
    int next_state;
    int finish_time;
    long long bytes_done, start_byte, size;
    int bytes_per_second;
	int delay_time;
	int outfd;
	int ready;
    NSString *message;
} 


-(id) init;
-(int) start;
-(int) run;
-(int) close;
//-(id) initWithName:(NSString *)name; 
//-(id) initWithSetting: (id)conn;
@property(copy) NSString *filename;
@property(copy) NSString *directory;
@property(copy) NSString *url;
@property(assign) int connections;
@property(assign) conf_t *conf;
@property(assign) axel_t *axel;
@property(copy) NSMutableDictionary *status;
@property(assign) double start_time;
@property(assign) int next_state;
@property(assign) int finish_time;
@property(assign) long long bytes_done, start_byte, size;
@property(assign) int bytes_per_second;
@property(assign) int delay_time;
@property(assign) int outfd;
@property(assign) int ready;
@property(copy) NSString *message;
@end
