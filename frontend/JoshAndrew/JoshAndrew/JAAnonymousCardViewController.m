//
//  JAAnonymousCardViewController.m
//  JoshAndrew
//
//  Created by Joshua Bell on 9/14/12.
//  Copyright (c) 2012 50cubes. All rights reserved.
//

#import "JAAnonymousCardViewController.h"

@interface JAAnonymousCardViewController ()

@end

@implementation JAAnonymousCardViewController
@synthesize answerLabel = _answerLabel;

- (id)initWithData:(NSDictionary*)aData
{
    self = [super initWithNibName:@"JAAnonymousCardViewController" bundle:[NSBundle mainBundle]];
    if (self)
    {
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
    [self setAnswerLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)dealloc
{
    
    [_answerLabel release];
    [super dealloc];
}
@end
