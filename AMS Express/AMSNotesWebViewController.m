//
//  AMSNotesWebViewController.m
//  AMS Express
//
//  Created by Colin on 7/30/14.
//  Copyright (c) 2014 Alpert Medical School. All rights reserved.
//

#import "AMSNotesWebViewController.h"

#import "AMSNotesHTMLParser.h"

@interface AMSNotesWebViewController ()

@end

@implementation AMSNotesWebViewController

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
    
    self.htmlParser = [[AMSNotesHTMLParser alloc] init];
//    self.htmlParser.delegate = 
    
    NSURL *url = [NSURL URLWithString:@"http://www2.hawaii.edu/~kinzie/documents/CV%20&%20pubs/list%20of%20pdfs.htm"];
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url];
    [self.webView loadRequest:urlRequest];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadRequestFromString:(NSString*)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:urlRequest];
}

#pragma mark - Web View delegate methods

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSURL *currentURL = [webView.request URL];
    NSLog(@"%@", currentURL);
    [self.htmlParser updateLinksArrayWithWebURL:currentURL];
}

@end