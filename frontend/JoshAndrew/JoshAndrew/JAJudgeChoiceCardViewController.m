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

- (IBAction)didSelectCard:(id)sender
{
    
    [_delegate didSelectCard:self];
}

- (id)initWithDelegate:(id<JAJudgeChoiceCardViewControllerDelegate>)aDelegate
{
    self = [super initWithNibName:@"JAJudgeChoiceCardViewController" bundle:nil];
    if (self) {
        // Custom initialization
        self.userID = nil;
        _delegate = aDelegate;
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
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


- (void)dealloc {
    [_answerText release];
    [waitingCover release];
    [super dealloc];
}
@end
