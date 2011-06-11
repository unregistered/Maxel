//
//  main.m
//  Maxel
//
//  Created by Chris Li on 5/31/11.
//

#import <Cocoa/Cocoa.h>

#import <MacRuby/MacRuby.h>

int main(int argc, char *argv[])
{
    return macruby_main("rb_main.rb", argc, argv);
}
