//
//  JARootViewController.m
//  JoshAndrew
//
//  Created by Joshua Bell on 9/13/12.
//  Copyright (c) 2012 50cubes. All rights reserved.
//

#import "JARootViewController.h"
#import "JAStartScreen.h" 
#import "JAPlayer.h"
#import "JAJudgeViewController.h"
#import "JAOratorViewController.h"

@interface JARootViewController ()

@end

@implementation JARootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setFrame:CGRectMake(0,0,kAppWidth, kAppHeight)];
    
	// Do any additional setup after loading the view.
    //    [self listFonts];
    JAPlayer *currentPlayer = [JAPlayer sharedInstance];
    currentPlayer.playerID = PLAYER;
#ifdef PLAYER
    switch (PLAYER) {
        case 1:
            currentPlayer.playerName = @"KittenColonyOnFire";
            break;
        case 2:
            currentPlayer.playerName = @"PankyPanda";
            break;
        case 3:
            currentPlayer.playerName = @"SkyDivingFlightlessBird";
            break;
        default:
            break;
    }
        
    
#else
    _tempUserId = abs(arc4random());
#endif
    
    
    
    NSLog( @"user id is : %d", currentPlayer.playerID );
    NSLog( @"user name is : %@", currentPlayer.playerName );

    
    JAStartScreen *startScreen = [[JAStartScreen alloc] init];
    [self addChildViewController:startScreen];
    [self.view addSubview:startScreen.view];
    [startScreen didMoveToParentViewController:self];
    _currentViewController = startScreen;
    [startScreen release];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

-(void)transitionToView:(UIViewController *)newView withCompletionBlock:(TransitionCompletion)completionBlock
{
    
    [self addChildViewController:newView];
    
    [_currentViewController willMoveToParentViewController:nil];
    [self transitionFromViewController:_currentViewController
                      toViewController:newView
                              duration:0
                               options:UIViewAnimationOptionTransitionNone
                            animations:nil
                            completion:^(BOOL finished)
     {
         [_currentViewController removeFromParentViewController];
         
         [newView didMoveToParentViewController:self];
         
         if( completionBlock != NULL )
             completionBlock(newView);
         
         _currentViewController = newView;
     }];
}


-(void)dealHandWithDictionaryData:(NSDictionary*)data
{
    
    if ( [[data objectForKey:@"play_type"] isEqual:@"judge"] )
    {
        
        NSLog(@"hand is judge type");
        JAJudgeViewController *judgeViewController = [[JAJudgeViewController alloc] initWithHandData:data];
        [self transitionToView:judgeViewController withCompletionBlock:NULL];
        [judgeViewController release];
    }
    else if ([[data objectForKey:@"play_type"] isEqual:@"orator"] )
    {
        
        NSLog(@"hand is orator type");
        JAOratorViewController *oratorViewController = [[JAOratorViewController alloc] initWithData:data];
        [self transitionToView:oratorViewController withCompletionBlock:NULL];
        [oratorViewController release];
    
    }
    else
    {
        
        NSLog(@"unrecognized play type");
    }
}



@end
