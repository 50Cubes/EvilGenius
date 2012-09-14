//
//  JAPlayer.m
//  JoshAndrew
//
//  Created by Joshua Bell on 9/13/12.
//  Copyright (c) 2012 50cubes. All rights reserved.
//

#import "JAPlayer.h"

@implementation JAPlayer
@synthesize playerID;
@synthesize playerName;

static JAPlayer * sharedSingleton_ = nil;
+ (JAPlayer*) sharedInstance
{
    if (sharedSingleton_ == nil)
    {
        
        sharedSingleton_ = [[super allocWithZone:NULL] init];
    }
    
    return sharedSingleton_;
}

+ (id) allocWithZone:(NSZone *)zone
{
    return [[self sharedInstance] retain];
}

- (id) copyWithZone:(NSZone*)zone
{
    return self;
}

- (id) retain
{
    return self;
}

- (NSUInteger) retainCount
{
    return NSUIntegerMax; // denotes an object that cannot be released
}

-(oneway void)release
{
    // do nothing
}
- (id) autorelease
{
    return self;
}
@end
