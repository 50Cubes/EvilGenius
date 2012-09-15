//
//  JAJudgeChoiceCardViewController.h
//  JoshAndrew
//
//  Created by Joshua Bell on 9/13/12.
//  Copyright (c) 2012 50cubes. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JAJudgeChoiceCardViewController;
@protocol JAJudgeChoiceCardViewControllerDelegate <NSObject>

-(void)didSelectCard:(JAJudgeChoiceCardViewController*)card;

@end

@interface JAJudgeChoiceCardViewController : UIViewController
{
    
    id<JAJudgeChoiceCardViewControllerDelegate> _delegate;
}
@property (retain, nonatomic) NSString *answerID;
@property (retain, nonatomic) NSString *userID;
@property (retain, nonatomic) IBOutlet UILabel *answerText;
@property (retain, nonatomic) IBOutlet UIView *waitingCover;
- (IBAction)didSelectCard:(id)sender;
- (id)initWithDelegate:(id<JAJudgeChoiceCardViewControllerDelegate>)aDelegate;

@end
