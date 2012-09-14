//
//  JAViewController.h
//  JoshAndrew
//
//  Created by Joshua Bell on 9/13/12.
//  Copyright (c) 2012 50cubes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAStartScreen : UIViewController
{
    
    NSURLConnection *_connection;
    NSMutableData *_responseData;
}

- (id)init;
- (IBAction)joinMatchDidTap:(id)sender;

@end
