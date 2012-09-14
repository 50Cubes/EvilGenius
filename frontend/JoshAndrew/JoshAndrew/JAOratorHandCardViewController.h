//
//  JAOratorHandCardViewController.h
//  JoshAndrew
//
//  Created by Joshua Bell on 9/14/12.
//  Copyright (c) 2012 50cubes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAOratorHandCardViewController : UIViewController
{
    
    NSDictionary *_data;
    NSString *_cardID;
    NSString *_cardText;
    NSString *_cardScore;
}

@property (retain, nonatomic) IBOutlet UILabel *answerText;
@property (retain, nonatomic) IBOutlet UILabel *score;

- (id)initWithData:(NSDictionary*)data;

@end
