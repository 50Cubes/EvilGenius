//
//  JAJudgeViewController.h
//  JoshAndrew
//
//  Created by Joshua Bell on 9/13/12.
//  Copyright (c) 2012 50cubes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAJudgeViewController : UIViewController
{
    
    NSDictionary *_data;
    NSString *_adLib;
    NSMutableArray *_cards;
    UIView *_scrollerContent;
}
@property (retain, nonatomic) IBOutlet UILabel *question;
@property (retain, nonatomic) IBOutlet UIScrollView *answerScroller;
- (IBAction)sendChoiceDidTap:(id)sender;
- (id)initWithHandData:(NSDictionary*)handData;

@end
