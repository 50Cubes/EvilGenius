//
//  JAOratorHandCardViewController.h
//  JoshAndrew
//
//  Created by Joshua Bell on 9/14/12.
//  Copyright (c) 2012 50cubes. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JAOratorHandCardViewController;
@protocol JAOratorHandCardViewControllerDelegate <NSObject>

-(void)didSelectCard:(JAOratorHandCardViewController*)card;

@end

@interface JAOratorHandCardViewController : UIViewController
{
    
    NSDictionary *_data;
    NSString *_cardID;
    NSString *_cardText;
    NSString *_cardScore;
    id<JAOratorHandCardViewControllerDelegate> _delegate;
}

@property (readonly, nonatomic) NSString *cardID;
@property (readonly, nonatomic) NSString *cardText;
@property (retain, nonatomic) IBOutlet UILabel *answerText;
@property (retain, nonatomic) IBOutlet UILabel *score;
- (IBAction)cardDidSelect:(id)sender;

- (id)initWithData:(NSDictionary*)aData delegate:(id<JAOratorHandCardViewControllerDelegate>)theDelegate;

@end
