//
//  JAJudgeChoiceCardViewController.m
//  JoshAndrew
//
//  Created by Joshua Bell on 9/13/12.
//  Copyright (c) 2012 50cubes. All rights reserved.
//

#import "JAJudgeChoiceCardViewController.h"

@interface JAJudgeChoiceCardViewController ()

@end

@implementation JAJudgeChoiceCardViewController
@synthesize answerText = _answerText;
@synthesize waitingCover;

- (id)init
{
    self = [super initWithNibName:@"JAJudgeChoiceCardViewController" bundle:nil];
    if (self) {
        // Custom initialization
        _hasAnswered = NO;
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
    [self setAnswerText:nil];
    [self setWaitingCover:nil];
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
    [waitingCover release];
    [super dealloc];
}
@end
