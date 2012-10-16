//
//  MGNViewController.m
//  FirstProjectTweeter
//
//  Created by Marco Antonio Rojo Marcondes on 06/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MGNViewController.h"
#import <Social/Social.h>
#import <Twitter/Twitter.h>

@interface MGNViewController()
  -(void) reloadTweets;

-(void) handleTwitterData: (NSData*) data
              urlResponse: (NSHTTPURLResponse*) urlResponse
                    error: (NSError*) error;
@end

@implementation MGNViewController

@synthesize twitterTextView = twitterTextView;

-(IBAction)handleTweetButtonTapped:(id)sender {
  [self sendMessage:SLServiceTypeTwitter];
}


-(IBAction)handleFacebookButtonTapped:(id)sender {
  [self sendMessage:SLServiceTypeFacebook];
}

-(void)sendMessage:(NSString *)serviceType{
  if ([SLComposeViewController isAvailableForServiceType: serviceType]){
    SLComposeViewController *tweetVC =
    [SLComposeViewController composeViewControllerForServiceType: serviceType];
    [tweetVC setInitialText: @"Primeira mensagem no io6"];
    [self presentViewController: tweetVC animated:YES completion:NULL];
  } else {
    NSLog(@"Não pode mandar mensagem");
  }
}


-(IBAction) handleShowMyTweetsTapped: (id) sender {
  [self reloadTweets];

}

-(void) reloadTweets {
  NSURL *twitterAPIURL = [NSURL URLWithString:
                          @"http://api.twitter.com/1/statuses/user_timeline.json"];
  
  NSDictionary *twitterParams = [NSDictionary dictionaryWithObjectsAndKeys:@"mrmarcondes", @"screen_name", nil];
  TWRequest *request = [[TWRequest alloc]
                        initWithURL:twitterAPIURL
                        parameters:twitterParams
                        requestMethod:TWRequestMethodGET];
  [request performRequestWithHandler: ^(NSData *responseData, 
                                        NSHTTPURLResponse *urlResponse, 
                                        NSError *error) {
    [self handleTwitterData:responseData
                urlResponse:urlResponse
                      error:error];    
  }];
}

-(void) handleTwitterData:(NSData *)data 
              urlResponse:(NSHTTPURLResponse *)urlResponse
                    error:(NSError *)error {
  NSError *jsonError = nil;
  NSJSONSerialization *jsonResponse = [NSJSONSerialization JSONObjectWithData:data 
                                                                      options:0
                                                                        error:&jsonError];
  
  if (!jsonError &&
      [jsonResponse isKindOfClass:[NSArray class]]) {
    dispatch_async(dispatch_get_main_queue(), ^ {
      NSArray *tweets = (NSArray*) jsonResponse;
      for (NSDictionary *tweetDict in tweets) {
        NSString *tweetText = [NSString stringWithFormat:@"%@ (%@)",
                               [tweetDict valueForKey:@"text"],
                               [tweetDict valueForKey:@"created_at"]];
        self.twitterTextView.text = [NSString stringWithFormat:@"%@%@\n\n",
                                     self.twitterTextView.text,
                                     tweetText];
      }
    });
  }
      
}

@end
