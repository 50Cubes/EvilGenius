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
    
    NSDictionary *_data;
}
@property (retain, nonatomic) IBOutlet UILabel *questionWithAnswer;
@property (retain, nonatomic) IBOutlet UILabel *winningPlayer;
@property (retain, nonatomic) IBOutlet UILabel *currentPlayerPostMatchScore;

- (id)initWithData:(NSDictionary*)aData;

@end
