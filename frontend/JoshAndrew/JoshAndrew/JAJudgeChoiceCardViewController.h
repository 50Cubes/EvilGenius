//
//  JAJudgeChoiceCardViewController.h
//  JoshAndrew
//
//  Created by Joshua Bell on 9/13/12.
//  Copyright (c) 2012 50cubes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAJudgeChoiceCardViewController : UIViewController

@property (nonatomic, assign) BOOL hasAnswered;
@property (retain, nonatomic) IBOutlet UILabel *answerText;
@property (retain, nonatomic) IBOutlet UIView *waitingCover;
- (id)init;

@end
