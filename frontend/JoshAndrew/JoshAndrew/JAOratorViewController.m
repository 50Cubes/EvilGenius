//
//  JAOratorViewController.m
//  JoshAndrew
//
//  Created by Joshua Bell on 9/14/12.
//  Copyright (c) 2012 50cubes. All rights reserved.
//

#import "JAOratorViewController.h"
#import "JAOratorHandCardViewController.h"
#import "JAPlayer.h"
#import "JSONKit.h"
#import "JARootViewController.h"

@interface JAOratorViewController ()
-(void)pingForJudgementReady;
-(void)updateOratorSubmissionsWithData:(NSDictionary*)data;
@end

@implementation JAOratorViewController
@synthesize instructionText = _instructionText;
@synthesize submitChoiceButton = _submitChoiceButton;
@synthesize question = _question;
@synthesize scollerOfAnswerCards = _scrollerOfAnswerCards;
@synthesize seeResultsButton = _seeResultsButton;

- (id)initWithData:(NSDictionary*)aData
{
    self = [super initWithNibName:@"JAOratorViewController" bundle:[NSBundle mainBundle]];
    if (self)
    {
        // Custom initialization
        _data = [aData retain];
        _questionText = [_data objectForKey:@"adlib"];
        _scrollerContent = [[UIView alloc] init];
        _cards = [[NSMutableArray alloc] init];
        _pingForFullMatchResponseData = [[NSMutableData alloc] init];
        _answerAdlibResponseData = [[NSMutableData alloc] init];
        _checkForSubmittedCardsResponseData = [[NSMutableData alloc] init];
        _selectedCard = nil;
        _submittedAnswers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [_question setText:_questionText];
    
    // Do any additional setup after loading the view from its nib.
    NSArray *handOfCards = [_data objectForKey:@"hand"];
    [_scrollerContent setFrame:CGRectMake(0, 0, ([handOfCards count] - 1) * 260, _scrollerOfAnswerCards.frame.size.height)];
    
    NSInteger cardNum = 0;
    for ( NSDictionary *cardData in handOfCards )
    {
        
        JAOratorHandCardViewController *cardUI = [[JAOratorHandCardViewController alloc] initWithData:cardData delegate:self];
        [cardUI.view setFrame:CGRectMake(cardNum * 250, 0, cardUI.view.frame.size.width, cardUI.view.frame.size.height)];
        [_cards addObject:cardUI];
        [_scrollerContent addSubview:cardUI.view];
        [cardUI release];
        ++cardNum;
    }
    
    [_scrollerOfAnswerCards addSubview:_scrollerContent];
    [_scrollerOfAnswerCards setContentSize:CGSizeMake(_scrollerContent.frame.size.width + 200, _scrollerContent.frame.size.height)];
    
    [self pingForFullMatch];
}

- (void)viewDidUnload
{
    [self setScollerOfAnswerCards:nil];
    [self setQuestion:nil];
    [self setSubmitChoiceButton:nil];
    [self setInstructionText:nil];
    [self setSeeResultsButton:nil];
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
    
    [_data release];
    [_scrollerOfAnswerCards release];
    [_question release];
    [_submitChoiceButton release];
    [_instructionText release];
    [_seeResultsButton release];
    [super dealloc];
}

- (IBAction)submitChoiceDidTap:(id)sender
{
    
    if ( _selectedCard != nil )
    {
        
        [_submitChoiceButton setHidden:YES];
        
        // tell backend of choice and transition to Global Game Board View
        //make synchronous blocking call
        NSString *params = [NSString stringWithFormat:@"?method=AnswerAdlib&user_id=%d&answer_id=%@&match_id=%@", [JAPlayer sharedInstance].playerID, _selectedCard.cardID, [JAPlayer sharedInstance].matchID];
        NSURL *urlToCheckIfAllPlayersJoinedMatch = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kBaseURL, params]];
        NSURLRequest *checkIfAllPlayersJoinedRequest = [NSURLRequest requestWithURL:urlToCheckIfAllPlayersJoinedMatch];
        
        
        _answerAdlibConnection = [[NSURLConnection connectionWithRequest:checkIfAllPlayersJoinedRequest delegate:self] retain];
        
    }
    
    
    
}

- (IBAction)seeResultsDidTap:(id)sender
{
    
    //all cards are in so show results screen
    [((JARootViewController*)([UIApplication sharedApplication].keyWindow.rootViewController)) showResultsScreenWithData:_readyForJudgementDictionary];
}
     
-(void)pingForFullMatch
 {
     
     //make asynchronous blocking call
     NSString *params = [NSString stringWithFormat:@"?method=PingForFullMatch&match_id=%@", [JAPlayer sharedInstance].matchID];
     NSURL *urlToCheckIfAllPlayersJoinedMatch = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kBaseURL, params]];
     NSURLRequest *checkIfAllPlayersJoinedRequest = [NSURLRequest requestWithURL:urlToCheckIfAllPlayersJoinedMatch];
     
     _pingForFullMatchConnection = [[NSURLConnection connectionWithRequest:checkIfAllPlayersJoinedRequest delegate:self] retain];
 }
 
 
 -(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
 {
     if ([response isKindOfClass:[NSHTTPURLResponse class]])
     {
         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
         //If you need the response, you can use it here
         NSLog( @"server response : %@", httpResponse );
     }
     
     if (connection == _pingForFullMatchConnection)
     {
         [_pingForFullMatchResponseData setLength:0];
     }
     else if ( connection == _answerAdlibConnection )
     {
         [_answerAdlibResponseData setLength:0];
     }
     else if ( connection == _checkForSubmittedCardsConnection )
     {
         
         [_checkForSubmittedCardsResponseData setLength:0];
     }
 }
 
 -(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
 {
     
     if (connection == _pingForFullMatchConnection)
     {
         
         [_pingForFullMatchResponseData appendData:data];
     }
     else if ( connection == _answerAdlibConnection )
     {
         
         [_answerAdlibResponseData appendData:data];
     }
     else if ( connection == _checkForSubmittedCardsConnection )
     {
         
         [_checkForSubmittedCardsResponseData appendData:data];

     }
 }
 
 -(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
 {
     NSLog( @"connectio nfailed with error : %@", error);
     
     if (connection == _pingForFullMatchConnection)
     {
         
         [_pingForFullMatchResponseData release];
     }
     else if ( connection == _answerAdlibConnection )
     {
         
         [_answerAdlibResponseData release];
     }
     else if ( connection == _checkForSubmittedCardsConnection )
     {
         
         [_checkForSubmittedCardsResponseData release];
         
     }
 }
 
 -(void) connectionDidFinishLoading:(NSURLConnection *)connection
 {
     if (connection == _pingForFullMatchConnection)
     {
         NSString *responseString = [[NSString alloc] initWithData:_pingForFullMatchResponseData encoding:NSUTF8StringEncoding];
//         NSLog( @"response string is : %@", responseString );
         NSDictionary *jsonDictionary = [responseString objectFromJSONString];
         
         // You've got all the data now
         // Do something with your response string
         NSLog( @"response dictionary is : %@", jsonDictionary );
         
         if ( [[jsonDictionary objectForKey:@"ready"] integerValue] == 0 )
         {
             
             [_pingForFullMatchConnection release];
             _pingForFullMatchConnection = nil;
             
             NSLog(@"not in match yet. attempting another ping in 5 seconds");
             // ping server for match again
             [self performSelector:@selector(pingForFullMatch) withObject:nil afterDelay:5];
         }
         else
         {
             
             [[JAPlayer sharedInstance] setMatchHasAllPlayers:YES];
         }
         [responseString release];
     }
     else if ( connection == _answerAdlibConnection )
     {
         
         NSString *answerAdlibResponseString = [[NSString alloc] initWithData:_answerAdlibResponseData encoding:NSUTF8StringEncoding];
//         NSLog( @"response string is : %@", answerAdlibResponseString );
         NSDictionary *answerAdlibJsonDictionary = [answerAdlibResponseString objectFromJSONString];
         
         // You've got all the data now
         // Do something with your response string
         NSLog( @"anserAdlib response dictionary is : %@", answerAdlibJsonDictionary );
        
         [self configureGlobalGameBoardView];
         
         [_answerAdlibConnection release];
         _answerAdlibConnection = nil;
         [answerAdlibResponseString release];

     }
     else if ( connection == _checkForSubmittedCardsConnection )
     {
         
         NSString *checkForSumbittedCardsResponseString = [[NSString alloc] initWithData:_checkForSubmittedCardsResponseData encoding:NSUTF8StringEncoding];
         //         NSLog( @"response string is : %@", answerAdlibResponseString );
         NSDictionary *checkForSumbittedCardsDictionary = [checkForSumbittedCardsResponseString objectFromJSONString];
         
         // You've got all the data now
         // Do something with your response string
         NSLog( @"submitted cards response dictionary is : %@", checkForSumbittedCardsDictionary );
         if ( [[checkForSumbittedCardsDictionary objectForKey:@"ready"] integerValue] == 0 )
         {
             
             NSLog(@"not all players cards are in. pinging for judgement in 5 seconds.");
             [self performSelector:@selector(pingForJudgementReady) withObject:nil afterDelay:5];
         }
         else
         {
             
             _readyForJudgementDictionary = checkForSumbittedCardsDictionary;
             [_seeResultsButton setHidden:NO];
             
         }
         
         [self updateOratorSubmissionsWithData:checkForSumbittedCardsDictionary];
     }
    
 }
 
-(void)didSelectCard:(JAOratorHandCardViewController*)card
{
    
    [_selectedCard.view setBackgroundColor:[UIColor whiteColor]];
    _selectedCard = card;
    [_selectedCard.view setBackgroundColor:[UIColor greenColor]];
}

-(void)configureGlobalGameBoardView
{
    
    NSLog( @"configure game board view");
    
    // configure global game view
    [_instructionText setText:@"Sumbitted cards:"];
    [_scrollerContent removeFromSuperview];
    
    //updated submitted cards
    [self pingForJudgementReady];
    
}

-(void)pingForJudgementReady
{
    
    // tell backend of choice and transition to Global Game Board View
    //make synchronous blocking call
    NSString *params = [NSString stringWithFormat:@"?method=PingForAnswers&match_id=%@", [JAPlayer sharedInstance].matchID];
    NSURL *urlToGetSubmittedCards = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kBaseURL, params]];
    NSURLRequest *checkForSubmittedCards = [NSURLRequest requestWithURL:urlToGetSubmittedCards];    
    _checkForSubmittedCardsConnection = [[NSURLConnection connectionWithRequest:checkForSubmittedCards delegate:self] retain];
}
-(void)updateOratorSubmissionsWithData:(NSDictionary*)data
{
    
    NSLog(@"add new cards if any: %@", data);
    
}


@end
