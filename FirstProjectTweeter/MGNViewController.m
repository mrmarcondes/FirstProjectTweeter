//
//  MGNViewController.m
//  FirstProjectTweeter
//
//  Created by Marco Antonio Rojo Marcondes on 06/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MGNViewController.h"
#import <Twitter/Twitter.h>

@interface MGNViewController()
  -(void) reloadTweets;
@end

@implementation MGNViewController

@synthesize twitterWebView = _twitterWebView;

-(IBAction)handleTweetButtonTapped:(id)sender {
  if (TWTweetComposeViewController.canSendTweet){
    TWTweetComposeViewController *tweetVC = 
      [TWTweetComposeViewController.alloc init];
    [tweetVC setInitialText: @"Primeiro projeto usando iOS SDK"];
    tweetVC.completionHandler = ^(TWTweetComposeViewControllerResult result)
    {
      if (result == TWTweetComposeViewControllerResultDone) {
        [self dismissModalViewControllerAnimated:YES];
        [self reloadTweets];
      }
    };
    [self presentViewController:tweetVC animated:YES completion:NULL];
  } else {
    NSLog(@"Não é possível enviar tweet");    
  }  
}

-(IBAction) handleShowMyTweetsTapped: (id) sender {
  [self reloadTweets];

}

-(void) reloadTweets {
  [self.twitterWebView loadRequest:
   [NSURLRequest requestWithURL:
    [NSURL URLWithString:@"http://twitter.com/mrmarcondes"]]];
}

@end
