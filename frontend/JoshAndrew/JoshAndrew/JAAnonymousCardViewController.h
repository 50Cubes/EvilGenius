//
//  JAAnonymousCardViewController.h
//  JoshAndrew
//
//  Created by Joshua Bell on 9/14/12.
//  Copyright (c) 2012 50cubes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAAnonymousCardViewController : UIViewController
{
    
    NSDictionary *_data;
}
@property (retain, nonatomic) IBOutlet UILabel *answerLabel;
- (id)initWithData:(NSDictionary*)aData;
@end
