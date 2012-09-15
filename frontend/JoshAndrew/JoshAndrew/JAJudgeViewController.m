//
//  JAJudgeViewController.m
//  JoshAndrew
//
//  Created by Joshua Bell on 9/13/12.
//  Copyright (c) 2012 50cubes. All rights reserved.
//

#import "JAJudgeViewController.h"
#import "JAJudgeChoiceCardViewController.h"
#import "JSONKit.h"
#import "JAPlayer.h"
#import "JAAnonymousCardViewController.h"
#import "JARootViewController.h"

@interface JAJudgeViewController ()
-(void)updateWithOratorAnswer:(NSArray*)answer;

@end

@implementation JAJudgeViewController
@synthesize submitChoiceButton = _submitChoiceButton;
@synthesize question = _question;
@synthesize answerScroller = _answerScroller;

- (id)initWithHandData:(NSDictionary*)handData
{
    self = [super initWithNibName:@"JAJudgeViewController" bundle:[NSBundle mainBundle]];
    if (self)
    {
        
        // Custom initialization
        _data = [handData retain];
        _adLib = [_data objectForKey:@"adlib"];
        _playerInfo = [[_data objectForKey:@"player_info"] retain];
        _cards = [[NSMutableArray alloc] init];
        _scrollerContent = [[UIView alloc] init];
        _checkForSubmittedCardsResponseData = [[NSMutableData alloc] init];
        _selectedCard = nil;
        _allSubmissionsIn = NO;
        _sendJudgementRequestData = [[NSMutableData alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    [_question setText:_adLib];
    NSArray *players = [_data objectForKey:@"player_info"];
    [_scrollerContent setFrame:CGRectMake(0, 0, [players count] * 250, _answerScroller.frame.size.height)];
    
    NSInteger cardNum = 0;
    for ( NSDictionary *playerInfo in players )
    {
        
        if ([[playerInfo objectForKey:@"play_type"] isEqual:@"orator"])
        {
            
            JAJudgeChoiceCardViewController *cardUI = [[JAJudgeChoiceCardViewController alloc] initWithDelegate:self];
            [cardUI.view setFrame:CGRectMake(cardNum * 250, 0, cardUI.view.frame.size.width, cardUI.view.frame.size.height)];
            [_cards addObject:cardUI];
            [_scrollerContent addSubview:cardUI.view];
            [cardUI release];
            ++cardNum;
        }
    }
    
    [_answerScroller addSubview:_scrollerContent];
    [_answerScroller setContentSize:_scrollerContent.frame.size];
    
    [self pingServerToCheckForAnswers];
}

- (void)viewDidUnload
{
    
    [self setQuestion:nil];
    [self setAnswerScroller:nil];
    [self setSubmitChoiceButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)dealloc {
    [_question release];
    [_answerScroller release];
    [_submitChoiceButton release];
    [super dealloc];
}

- (IBAction)sendChoiceDidTap:(id)sender
{
    
    // send choice
    
    if (_selectedCard != nil)
    {
        
        [JAPlayer sharedInstance].matchQuestion = _question.text;
        [JAPlayer sharedInstance].matchAnswer = _selectedCard.answerText.text;
        NSString *params = [NSString stringWithFormat:@"?method=JudgeSelect&match_id=%@&answer_id=%@&user_id=%d", [JAPlayer sharedInstance].matchID, _selectedCard.answerID, [JAPlayer sharedInstance].playerID];
        NSURL *urlToGetSubmittedCards = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kBaseURL, params]];
        NSURLRequest *checkForSubmittedCards = [NSURLRequest requestWithURL:urlToGetSubmittedCards];
        _sendJudgementConnection = [[NSURLConnection connectionWithRequest:checkForSubmittedCards delegate:self] retain];
    }
}


-(void)pingServerToCheckForAnswers
{
    
    // tell backend of choice and transition to Global Game Board View
    // make asynchronous blocking call
    NSString *params = [NSString stringWithFormat:@"?method=PingForAnswers&match_id=%@", [JAPlayer sharedInstance].matchID];
    NSURL *urlToGetSubmittedCards = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kBaseURL, params]];
    NSURLRequest *checkForSubmittedCards = [NSURLRequest requestWithURL:urlToGetSubmittedCards];
    _checkForSubmittedCardsConnection = [[NSURLConnection connectionWithRequest:checkForSubmittedCards delegate:self] retain];
}

-(void)updateWithOratorAnswer:(NSArray*)currentAnswers
{
    

    
    for ( NSDictionary *answerData in currentAnswers )
    {
        
//        NSString *cardID = [cardData objectForKey:@"id"];
        NSLog( @"ansewrid : %@", [answerData objectForKey:@"answer_id"]);
        NSLog( @"ansewrText : %@", [answerData objectForKey:@"answer_text"]);
        NSLog( @"userID : %@", [answerData objectForKey:@"user_id"]);
        BOOL userHasPlayedACard = NO;
        for ( JAJudgeChoiceCardViewController *card in _cards )
        {
            
            if ( [card.userID isEqualToString:[answerData objectForKey:@"answer_id"]] )
            {
                
                userHasPlayedACard = YES;
                break;
            }
        }
        
        if ( !userHasPlayedACard )
        {
            
            for ( JAJudgeChoiceCardViewController *card in _cards )
            {
                
                if ( card.userID == nil)
                {
                    
                    //update card with data
                    card.userID = [answerData objectForKey:@"user_id"];
                    [card.answerText setText:[answerData objectForKey:@"answer_text"]];
                    card.answerID = [answerData objectForKey:@"answer_id"];
                    [card.waitingCover setHidden:YES];
                    break;
                }
            }
        }
    }
    
}


-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([response isKindOfClass:[NSHTTPURLResponse class]])
    {
//        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
        //If you need the response, you can use it here
//        NSLog( @"server response : %@", httpResponse );
    }
    
    if (connection == _checkForSubmittedCardsConnection)
    {
        [_checkForSubmittedCardsResponseData setLength:0];
    }
    else if ( connection == _sendJudgementConnection)
    {
        
        [_sendJudgementRequestData setLength:0];

    }
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    
    if (connection == _checkForSubmittedCardsConnection)
    {
        
        [_checkForSubmittedCardsResponseData appendData:data];
    }
    else if ( connection == _sendJudgementConnection)
    {
        
        [_sendJudgementRequestData appendData:data];

    }
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog( @"connectio nfailed with error : %@", error);
    
    if (connection == _checkForSubmittedCardsConnection)
    {
        
        [_checkForSubmittedCardsResponseData release];
    }
    else if ( connection == _sendJudgementConnection)
    {
        
        [_sendJudgementRequestData release];

    }
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (connection == _checkForSubmittedCardsConnection)
    {
        NSString *checkForSubmittedCardsResponseString = [[NSString alloc] initWithData:_checkForSubmittedCardsResponseData encoding:NSUTF8StringEncoding];
        //         NSLog( @"response string is : %@", responseString );
        NSDictionary *checkForSubmittedCardsResponseDictionary = [checkForSubmittedCardsResponseString objectFromJSONString];
        
        if ([[checkForSubmittedCardsResponseDictionary objectForKey:@"ready"] integerValue] == 0)
        {
            
            // update ui and check for more answers
            
            NSLog(@"did not receive all answers");
            [self performSelector:@selector(pingServerToCheckForAnswers) withObject:nil afterDelay:5];
        }
        else
        {
            
            // judgement time is now
            [_submitChoiceButton setEnabled:YES];
            [_submitChoiceButton setAlpha:1];
            _allSubmissionsIn = YES;
            
        }

        [self updateWithOratorAnswer:[checkForSubmittedCardsResponseDictionary objectForKey:@"answers"]];
        
        // You've got all the data now
        // Do something with your response string
        NSLog( @"checkForSubmittedCardsResponseDictionary dictionary is : %@", checkForSubmittedCardsResponseDictionary );
        
        [_checkForSubmittedCardsConnection release];
        _checkForSubmittedCardsConnection = nil;
        [checkForSubmittedCardsResponseString release];
    }
    else if ( connection == _sendJudgementConnection)
    {
        
        NSString *judgementResponseString = [[NSString alloc] initWithData:_sendJudgementRequestData encoding:NSUTF8StringEncoding];
        //         NSLog( @"response string is : %@", responseString );
        NSDictionary *judgementResponseDictionary = [judgementResponseString objectFromJSONString];
        NSLog(@"jdugement response dictionary %@ ", judgementResponseDictionary);
        
        [((JARootViewController*)([UIApplication sharedApplication].keyWindow.rootViewController)) showResultsScreenWithScore:[judgementResponseDictionary objectForKey:@"score"] winnerID:_selectedCard.userID answerText:nil];
    }
}

-(void)didSelectCard:(JAJudgeChoiceCardViewController*)card
{
    if (_allSubmissionsIn)
    {
        if ( _selectedCard != nil )
        {
            
            [_selectedCard.view setBackgroundColor:[UIColor whiteColor]];
            [_selectedCard release];
            _selectedCard = nil;            
        }
        
        _selectedCard = [card retain];
        [_selectedCard.view setBackgroundColor:[UIColor greenColor]];
    }
}

@end
