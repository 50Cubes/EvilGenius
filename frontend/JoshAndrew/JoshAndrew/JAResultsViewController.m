//
//  JAJudgeResultsViewController.m
//  JoshAndrew
//
//  Created by Joshua Bell on 9/14/12.
//  Copyright (c) 2012 50cubes. All rights reserved.
//

#import "JAResultsViewController.h"
#import "JAPlayer.h"

@interface JAResultsViewController ()

@end

@implementation JAResultsViewController
@synthesize questionWithAnswer = _questionWithAnswer;
@synthesize winningPlayer = _winningPlayer;
@synthesize currentPlayerPostMatchScore = _currentPlayerPostMatchScore;

- (id)initWithData:(NSDictionary*)aData
{
    self = [super initWithNibName:@"JAResultsViewController" bundle:[NSBundle mainBundle]];
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
//    _questionWithAnswer = 
    
}

- (void)viewDidUnload
{
    [self setQuestionWithAnswer:nil];
    [self setWinningPlayer:nil];
    [self setCurrentPlayerPostMatchScore:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}
-(void)dealloc
{
    
    [_data release];
    [_questionWithAnswer release];
    [_winningPlayer release];
    [_currentPlayerPostMatchScore release];
    [super dealloc];
}
@end
