//
//  JAPlayer.h
//  JoshAndrew
//
//  Created by Joshua Bell on 9/13/12.
//  Copyright (c) 2012 50cubes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JAPlayer : NSObject
{
}

+ (JAPlayer *) sharedInstance;

@property (nonatomic, assign) NSInteger playerID;
@property (nonatomic, assign) NSString *playerName;

@end
