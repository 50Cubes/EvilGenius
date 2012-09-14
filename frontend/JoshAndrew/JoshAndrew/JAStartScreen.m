//
//  JAViewController.m
//  JoshAndrew
//
//  Created by Joshua Bell on 9/13/12.
//  Copyright (c) 2012 50cubes. All rights reserved.
//

#import "JAStartScreen.h"
#import "JAPlayer.h"
#import "JSONKit.h"
#import "JARootViewController.h"

@interface JAStartScreen ()

@end

@implementation JAStartScreen

- (id)init
{
    self = [super initWithNibName:@"JAStartScreen" bundle:[NSBundle mainBundle]];
    if (self)
    {
        
        // Custom initialization
        _responseData = [[NSMutableData alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
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

- (IBAction)joinMatchDidTap:(id)sender
{
    
    //make synchronous blocking call
    NSString *params = [NSString stringWithFormat:@"?method=Match&user_id=%d&user_name=%@", [JAPlayer sharedInstance].playerID, [JAPlayer sharedInstance].playerName];
    NSURL *urlToJoinMatch = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kBaseURL, params]];
    NSURLRequest *joinMatchRequest = [NSURLRequest requestWithURL:urlToJoinMatch];

    _connection = [[NSURLConnection connectionWithRequest:joinMatchRequest delegate:self] retain];
}


-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([response isKindOfClass:[NSHTTPURLResponse class]])
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
        //If you need the response, you can use it here
        NSLog( @"server response : %@",httpResponse );
    }
    
    [_responseData setLength:0];
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_responseData appendData:data];
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [_responseData release];
    [connection release];
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (connection == _connection)
    {
        NSString *responseString = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
        NSLog( @"response string is : %@", responseString );
        NSDictionary *jsonDictionary = [responseString objectFromJSONString];
        
        // You've got all the data now
        // Do something with your response string
        NSLog( @"response dictionary is : %@", jsonDictionary );
        JARootViewController *rootViewController = (JARootViewController*)[[UIApplication sharedApplication].keyWindow rootViewController];
        [rootViewController dealHandWithDictionaryData:jsonDictionary];
        [responseString release];
    }
    
    [_responseData release];
    [connection release];
}
@end
