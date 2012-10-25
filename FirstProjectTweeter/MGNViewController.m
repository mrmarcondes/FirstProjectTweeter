//
//  MGNViewController.m
//  FirstProjectTweeter
//
//  Created by Marco Antonio Rojo Marcondes on 06/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MGNViewController.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>


@interface MGNViewController()
@property (nonatomic, strong) IBOutlet UITextView *twitterTextView;
@property (strong) ACAccountStore *accountStore;
@property (readonly, strong) ACAccount *twitterAccount;

-(void) reloadTweets;

-(void) handleTwitterData: (NSData*) data
              urlResponse: (NSHTTPURLResponse*) urlResponse
                    error: (NSError*) error;
@end

@implementation MGNViewController

@synthesize twitterAccount = _twitterAccount;

-(ACAccount*) twitterAccount {
  if (!_twitterAccount) {
    self.accountStore = [[ACAccountStore alloc] init];
    ACAccountType *twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    NSArray *twitterAccounts = [self.accountStore accountsWithAccountType: twitterAccountType];
    if ([twitterAccounts count] > 0) {
      _twitterAccount = [twitterAccounts objectAtIndex:0];
    }
  }
  return _twitterAccount;
  
}

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
    NSLog(@"%@", tweetVC.class);
    [tweetVC setInitialText: NSLocalizedString(@"Primeira mensagem no io6", nil)];
    tweetVC.completionHandler = ^(SLComposeViewControllerResult result){
      if (result == SLComposeViewControllerResultDone){
        [self dismissViewControllerAnimated:YES completion:NULL];
        [self reloadTweets];
      }
    };
    
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
                          @"http://api.twitter.com/1/statuses/home_timeline.json"];
  
  NSDictionary *twitterParams = @{};
  SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                          requestMethod:SLRequestMethodGET
                                                    URL:twitterAPIURL
                                             parameters:twitterParams];
  
  request.account = self.twitterAccount;
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
  
  if ([jsonResponse isKindOfClass:[NSArray class]]) {
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
