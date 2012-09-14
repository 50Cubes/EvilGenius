//
//  JAOratorHandCardViewController.m
//  JoshAndrew
//
//  Created by Joshua Bell on 9/14/12.
//  Copyright (c) 2012 50cubes. All rights reserved.
//

#import "JAOratorHandCardViewController.h"

@interface JAOratorHandCardViewController ()

@end

@implementation JAOratorHandCardViewController
@synthesize answerText = _answerText;
@synthesize score = _score;

- (id)initWithData:(NSDictionary*)aData
{
    self = [super initWithNibName:@"JAOratorHandCardViewController" bundle:[NSBundle mainBundle]];
    if (self)
    {
        // Custom initialization
        _data = aData;
        _cardID = [_data objectForKey:@"id"];
        _cardText = [_data objectForKey:@"text"];
        _cardScore = [_data objectForKey:@"score"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [_answerText setText:_cardText];
    [_score setText:_cardScore];
    
}

- (void)viewDidUnload
{
    [self setAnswerText:nil];
    [self setScore:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)dealloc {
    [_answerText release];
    [_score release];
    [super dealloc];
}
@end
