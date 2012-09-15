//
//  JARootViewController.h
//  JoshAndrew
//
//  Created by Joshua Bell on 9/13/12.
//  Copyright (c) 2012 50cubes. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^TransitionCompletion)(UIViewController *newVC);
@interface JARootViewController : UIViewController
{
 
    UIViewController *_currentViewController;
}

-(void)dealHandWithDictionaryData:(NSDictionary*)data;
-(void)showResultsScreenWithScore:(NSString*)playerScore winnerID:(NSString*)theWinnerID answerText:(NSString*)theAnswerText;
-(void)showStartScreen;

@end
