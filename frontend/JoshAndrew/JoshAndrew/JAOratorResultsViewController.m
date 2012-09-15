//
//  JAOratorResultsViewController.m
//  JoshAndrew
//
//  Created by Joshua Bell on 9/14/12.
//  Copyright (c) 2012 50cubes. All rights reserved.
//

#import "JAOratorResultsViewController.h"

@interface JAOratorResultsViewController ()

@end

@implementation JAOratorResultsViewController

- (id)initWithData:(NSDictionary*)aData
{
    self = [super initWithNibName:@"JAOratorResultsViewController" bundle:[NSBundle mainBundle]];
    if (self) {
        // Custom initialization
        _data = [aData retain];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end
