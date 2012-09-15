//
//  JAJudgeResultsViewController.h
//  JoshAndrew
//
//  Created by Joshua Bell on 9/14/12.
//  Copyright (c) 2012 50cubes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAResultsViewController : UIViewController
{
    
//    NSDictionary *_data;
    NSString *_playerscore;
    NSString *_winnerID;
    NSString *_answerTextForOrator;
}
@property (retain, nonatomic) IBOutlet UILabel *question;
@property (retain, nonatomic) IBOutlet UILabel *answer;

@property (retain, nonatomic) IBOutlet UILabel *winningPlayer;
@property (retain, nonatomic) IBOutlet UILabel *currentPlayerPostMatchScore;
- (IBAction)playAgainDidTap:(id)sender;

- (id)initWithScore:(NSString*)playerScore winnerID:(NSString*)theWinnerID answerText:(NSString*)theAnswerText;

@end
