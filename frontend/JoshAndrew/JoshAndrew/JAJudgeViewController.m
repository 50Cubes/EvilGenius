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

@interface JAJudgeViewController ()
-(void)updateWithOratorAnswer:(NSDictionary*)answer;

@end

@implementation JAJudgeViewController
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
        _cards = [[NSMutableArray alloc] init];
        _scrollerContent = [[UIView alloc] init];
        
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    [_question setText:_adLib];
    NSArray *players = [_data objectForKey:@"player_info"];
    [_scrollerContent setFrame:CGRectMake(0, 0, ([players count] - 1) * 250, _answerScroller.frame.size.height)];
    
    NSInteger cardNum = 0;
    for ( NSDictionary *playerInfo in players )
    {
        
        if ([[playerInfo objectForKey:@"play_type"] isEqual:@"orator"])
        {
            
            JAJudgeChoiceCardViewController *cardUI = [[JAJudgeChoiceCardViewController alloc] init];
            [cardUI.view setFrame:CGRectMake(cardNum * 250, 0, cardUI.view.frame.size.width, cardUI.view.frame.size.height)];
            [_cards addObject:cardUI];
            [_scrollerContent addSubview:cardUI.view];
            [cardUI release];
            ++cardNum;
        }
    }
    
    [_answerScroller addSubview:_scrollerContent];
    [_answerScroller setContentSize:_scrollerContent.frame.size];
}

- (void)viewDidUnload
{
    
    [self setQuestion:nil];
    [self setAnswerScroller:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
	return YES;
}

- (void)dealloc {
    [_question release];
    [_answerScroller release];
    [super dealloc];
}

- (IBAction)sendChoiceDidTap:(id)sender
{
    
}


-(void)pingServerToCheckForAnswers
{
    
    
}

-(void)updateWithOratorAnswer:(NSDictionary*)answer
{
    
    
}

@end
