//
//  JAJudgeResultsViewController.m
//  JoshAndrew
//
//  Created by Joshua Bell on 9/14/12.
//  Copyright (c) 2012 50cubes. All rights reserved.
//

#import "JAResultsViewController.h"
#import "JAPlayer.h"
#import "JARootViewController.h"

@interface JAResultsViewController ()

@end

@implementation JAResultsViewController
@synthesize question = _question;
@synthesize answer = _answer;
@synthesize winningPlayer = _winningPlayer;
@synthesize currentPlayerPostMatchScore = _currentPlayerPostMatchScore;

- (IBAction)playAgainDidTap:(id)sender
{
    
    [((JARootViewController*)[UIApplication sharedApplication].keyWindow.rootViewController) showStartScreen];
}

- (id)initWithScore:(NSString*)playerScore winnerID:(NSString*)theWinnerID answerText:(NSString*)theAnswerText
{
    self = [super initWithNibName:@"JAResultsViewController" bundle:[NSBundle mainBundle]];
    if (self)
    {
        // Custom initialization
//        _data = [aData retain];
        _playerscore = [playerScore retain];
        _winnerID = [theWinnerID retain];
        _answerTextForOrator = [theAnswerText retain];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    _questionWithAnswer = 
    [_currentPlayerPostMatchScore setText:[NSString stringWithFormat:@"Your score is now: %@", _playerscore]];
    NSArray *playerInfo = [[JAPlayer sharedInstance].matchData objectForKey:@"player_info"];
    NSString *winnerName = @"Anonymous";
    for (NSDictionary *player in playerInfo )
    {
        if ( [[player objectForKey:@"user_id"] isEqualToString:_winnerID])
        {
            
            winnerName = [player objectForKey:@"user_name"];
        }
    }
    
    [_winningPlayer setText:[NSString stringWithFormat:@"%@ had the winning card!", winnerName]];
    [_question setText:[JAPlayer sharedInstance].matchQuestion];
    if ( [JAPlayer sharedInstance].playerType == JAPlayerTypeOrator )
    {
        [_answer setText:_answerTextForOrator];
    }
    else
    {
        [_answer setText:[JAPlayer sharedInstance].matchAnswer];
    }
}

- (void)viewDidUnload
{
    [self setWinningPlayer:nil];
    [self setCurrentPlayerPostMatchScore:nil];
    [self setQuestion:nil];
    [self setAnswer:nil];
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
    
//    [_data release];
//    [_questionWithAnswer release];
    [_winningPlayer release];
    [_currentPlayerPostMatchScore release];
    [_question release];
    [_answer release];
    [super dealloc];
}
@end
