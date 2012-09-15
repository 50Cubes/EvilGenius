//
//  JAJudgeViewController.h
//  JoshAndrew
//
//  Created by Joshua Bell on 9/13/12.
//  Copyright (c) 2012 50cubes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAJudgeChoiceCardViewController.h"

@interface JAJudgeViewController : UIViewController <JAJudgeChoiceCardViewControllerDelegate>
{
    
    NSDictionary *_data;
    NSString *_adLib;
    NSArray *_playerInfo;
    NSMutableArray *_cards;
    UIView *_scrollerContent;
    NSURLConnection *_checkForSubmittedCardsConnection;
    NSMutableData *_checkForSubmittedCardsResponseData;
    //keys are card id's and values are jaanonymousCard objects
    JAJudgeChoiceCardViewController *_selectedCard;
    BOOL _allSubmissionsIn;
    NSURLConnection *_sendJudgementConnection;
    NSMutableData *_sendJudgementRequestData;
}
@property (retain, nonatomic) IBOutlet UIButton *submitChoiceButton;
@property (retain, nonatomic) IBOutlet UILabel *question;
@property (retain, nonatomic) IBOutlet UIScrollView *answerScroller;
- (IBAction)sendChoiceDidTap:(id)sender;
- (id)initWithHandData:(NSDictionary*)handData;

@end
