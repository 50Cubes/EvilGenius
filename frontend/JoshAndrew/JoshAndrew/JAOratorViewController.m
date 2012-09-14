//
//  JAOratorViewController.m
//  JoshAndrew
//
//  Created by Joshua Bell on 9/14/12.
//  Copyright (c) 2012 50cubes. All rights reserved.
//

#import "JAOratorViewController.h"
#import "JAOratorHandCardViewController.h"

@interface JAOratorViewController ()

@end

@implementation JAOratorViewController
@synthesize question = _question;
@synthesize scollerOfAnswerCards = _scrollerOfAnswerCards;

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
        
        JAOratorHandCardViewController *cardUI = [[JAOratorHandCardViewController alloc] initWithData:cardData];
        [cardUI.view setFrame:CGRectMake(cardNum * 250, 0, cardUI.view.frame.size.width, cardUI.view.frame.size.height)];
        [_cards addObject:cardUI];
        [_scrollerContent addSubview:cardUI.view];
        [cardUI release];
        ++cardNum;
    }
    
    [_scrollerOfAnswerCards addSubview:_scrollerContent];
    [_scrollerOfAnswerCards setContentSize:CGSizeMake(_scrollerContent.frame.size.width + 200, _scrollerContent.frame.size.height)];
    
    
}

- (void)viewDidUnload
{
    [self setScollerOfAnswerCards:nil];
    [self setQuestion:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)dealloc
{
    
    [_data release];
    [_scrollerOfAnswerCards release];
    [_question release];
    [super dealloc];
}
- (IBAction)submitChoiceDidTap:(id)sender {
}
@end
