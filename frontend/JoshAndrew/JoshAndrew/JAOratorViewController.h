//
//  JAOratorViewController.h
//  JoshAndrew
//
//  Created by Joshua Bell on 9/14/12.
//  Copyright (c) 2012 50cubes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAOratorHandCardViewController.h"

@interface JAOratorViewController : UIViewController <JAOratorHandCardViewControllerDelegate, NSURLConnectionDelegate>
{
    
    NSDictionary *_data;
    NSString *_questionText;
    UIView *_scrollerContent;
    NSMutableArray *_cards;
    NSURLConnection *_pingForFullMatchConnection;
    NSURLConnection *_answerAdlibConnection;
    NSURLConnection *_checkForSubmittedCardsConnection;
    NSMutableData *_pingForFullMatchResponseData;
    NSMutableData *_answerAdlibResponseData;
    NSMutableData *_checkForSubmittedCardsResponseData;
    JAOratorHandCardViewController *_selectedCard;
    NSDictionary *_readyForJudgementDictionary;
    NSMutableArray *_submittedAnswers;
    BOOL _initializedWaitingOnSubmissionsCards;
    UIView *_submissionsContentScroller;
    NSArray *_playerInfo;
    NSURLConnection *_checkForJudgementDoneConnection;
    NSMutableData *_checkForJudgementDoneResponseData;
    NSString *_resultingScoreForCurPlayer;
    NSString *_winnerID;
    NSString *_answerText;
}
@property (retain, nonatomic) IBOutlet UILabel *instructionText;
@property (retain, nonatomic) IBOutlet UIButton *submitChoiceButton;
@property (retain, nonatomic) IBOutlet UILabel *question;
@property (retain, nonatomic) IBOutlet UIScrollView *scollerOfAnswerCards;
@property (retain, nonatomic) IBOutlet UIButton *seeResultsButton;
- (IBAction)submitChoiceDidTap:(id)sender;
- (IBAction)seeResultsDidTap:(id)sender;
- (id)initWithData:(NSDictionary*)aData;

@end
