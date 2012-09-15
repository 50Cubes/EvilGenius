//
//  JAOratorViewController.h
//  JoshAndrew
//
//  Created by Joshua Bell on 9/14/12.
//  Copyright (c) 2012 50cubes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAOratorViewController : UIViewController
{
    
    NSDictionary *_data;
    NSString *_questionText;
    UIView *_scrollerContent;
    NSMutableArray *_cards;
}
@property (retain, nonatomic) IBOutlet UILabel *question;
@property (retain, nonatomic) IBOutlet UIScrollView *scollerOfAnswerCards;
- (IBAction)submitChoiceDidTap:(id)sender;
- (id)initWithData:(NSDictionary*)aData;

@end
