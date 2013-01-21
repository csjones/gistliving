//
//  WebVC.m
//  gistliving
//
//  Created by crkmnstr on 1/21/13.
//  Copyright (c) 2013 csjones. All rights reserved.
//

#import "WebVC.h"
#import "ZAActivityBar.h"

@interface WebVC ()

@end

@implementation WebVC

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    [_webView loadRequest:_urlRequest];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if(![ZAActivityBar isVisible])
        [ZAActivityBar showWithStatus:@"Loading Web Page" forAction:@"web"];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if([ZAActivityBar isVisible])
        [ZAActivityBar showSuccessWithStatus:@"Finished Loading Web Page" forAction:@"web"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if([ZAActivityBar isVisible])
        [ZAActivityBar showErrorWithStatus:@"Failed Loading Web Page" forAction:@"web"];
}

@end
