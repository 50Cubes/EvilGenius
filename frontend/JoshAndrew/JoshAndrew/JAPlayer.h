//
//  JAPlayer.h
//  JoshAndrew
//
//  Created by Joshua Bell on 9/13/12.
//  Copyright (c) 2012 50cubes. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    JAPlayerTypeOrator = 1,
    JAPlayerTypeJudge = 2
    
}JAPlayerType;

@interface JAPlayer : NSObject
{
}

+ (JAPlayer *) sharedInstance;

@property (nonatomic, assign) NSInteger playerID;
@property (nonatomic, assign) NSString *playerName;
@property (nonatomic, assign) NSString *matchID;
@property (nonatomic, assign) BOOL matchHasAllPlayers;
@property (nonatomic, assign) JAPlayerType playerType;
@property (nonatomic, retain) NSDictionary *matchData;
@property (nonatomic, retain) NSString *matchAnswer;
@property (nonatomic, retain) NSString *matchQuestion;

@end
