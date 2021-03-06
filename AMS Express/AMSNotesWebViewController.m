//
//  AMSNotesWebViewController.m
//  AMS Express
//
//  Created by Colin on 7/30/14.
//  Copyright (c) 2014 Alpert Medical School. All rights reserved.
//

#import "AMSNotesWebViewController.h"

#import "AMSNotesMasterViewController.h"
#import "AMSNotesDataSourceController.h"

#import "AMSSettingsFileManager.h"

@interface AMSNotesWebViewController ()

@property BOOL isLoading;
@property BOOL isLoggedIn;
@property NSString *canvasURL;
@property (nonatomic, strong) UIBarButtonItem *openInBarButtonItem;

@end

@implementation AMSNotesWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self spinPic];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self spinPic];
    [self setCanvasURL];
    [self loadRequestFromString:self.canvasURL];
    [self.webView setBackgroundColor:[UIColor darkGrayColor]];
    self.webView.scalesPageToFit = YES;
    
    UINavigationController *masterNav = (UINavigationController *)[self.splitViewController.viewControllers firstObject];
    AMSNotesMasterViewController *masterVC = (AMSNotesMasterViewController *)[masterNav topViewController];
    self.dataSourceController = masterVC.dataSourceController;
    
    self.openInBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(openInAction)];
    self.interactionController = [[UIDocumentInteractionController alloc] init];
    
    UIBarButtonItem *stopBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopAction)];
    UIBarButtonItem *refreshBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshAction)];
    UIBarButtonItem *homeBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(homeAction)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *forwardBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(forwardAction)];
    UIBarButtonItem *rewindBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(rewindAction)];
    
    self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:stopBarButtonItem, refreshBarButtonItem, homeBarButtonItem, flexibleSpace, forwardBarButtonItem, rewindBarButtonItem, nil];
    
    NSURL *url = [NSURL URLWithString:@"http://canvas.brown.edu"];
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url];
    [self.webView loadRequest:urlRequest];
    
    UINavigationController *nav = (UINavigationController *)[self.splitViewController.viewControllers firstObject];
    self.delegate = (AMSNotesMasterViewController *)[nav topViewController];
    [self.delegate webViewControllerDidFinishLoading:self];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([self.pageTitle.text isEqualToString:@"Brown University Authentication for Web-Based Services"])
    {
        [self insertCredentialsWithWebView:self.webView];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)loadRequestFromString:(NSString*)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:urlRequest];
}

#pragma mark - Web View delegate methods
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.pageTitle.text = @"Loading";
    self.isLoading = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString* pageTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.pageTitle.text = pageTitle;
    self.isLoading = NO;
    
    self.currentURL = [webView.request.URL absoluteString];
    
    self.interactionController.URL = [NSURL fileURLWithPath:self.currentURL];
    if ([[self.currentURL substringFromIndex:(self.currentURL.length - 4)] isEqualToString:@".pdf"]) {
        [self toggleOpenInButtonOn:YES];
    } else {
        [self toggleOpenInButtonOn:NO];
    }
    
    if ([self.pageTitle.text isEqualToString:@"Canvas"]){
        self.isLoggedIn = NO;
    }
    if (!self.isLoggedIn) {
        [self insertCredentialsWithWebView:webView];
        self.isLoggedIn = YES;
    }
}

-(void)scanForPDFs
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"HTMLParser" withExtension:@"js"];
    NSString *parser = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    NSString *json = [self.webView stringByEvaluatingJavaScriptFromString:parser];
    NSLog(@"parser json: %@", json);
    
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *pdfLinkTuples = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    NSLog(@"pdfLinks: %@", pdfLinkTuples);
    [self.dataSourceController addLinksToTable:pdfLinkTuples];
}

-(void)rewindAction
{
    [self.webView goBack];
}

-(void)forwardAction
{
    [self.webView goForward];
}

-(void)openInAction
{
    [self.interactionController presentOpenInMenuFromBarButtonItem:self.openInBarButtonItem animated:YES];
}

-(void)homeAction
{
    if (self.teachImage.alpha > 0.0f) {
        self.teachImage.alpha = 0.0f;
    }
    if (self.attentionImage.alpha > 0.0f) {
        self.attentionImage.alpha = 0.0f;
    }
    [self setCanvasURL];
    [self loadRequestFromString:self.canvasURL];
}

-(void)refreshAction
{
    [self.webView reload];
}

-(void)stopAction
{
    [self.webView stopLoading];
}

- (void) spinPic
{
    if([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        UIImage *portraitImage = [UIImage imageNamed: @"AMSXTeachImage.png"];
        [self.teachImage setImage:portraitImage];
    }
    
    if( [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight){
        UIImage *landscapeImage = [UIImage imageNamed: @"AMSXTeachImageHorizontal.png"];
        [self.teachImage setImage:landscapeImage];
    }
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation) fromInterfaceOrientation{
    [self spinPic];
}
#pragma mark - Private methods

- (void)toggleOpenInButtonOn:(BOOL)on;
{
    NSMutableArray *rightBarButtonItems = [NSMutableArray arrayWithArray:self.navigationItem.rightBarButtonItems];
    
    if ([rightBarButtonItems containsObject:self.openInBarButtonItem] && !on) {
        [rightBarButtonItems removeObject:self.openInBarButtonItem];
    } else if (![rightBarButtonItems containsObject:self.openInBarButtonItem] && on) {
        [rightBarButtonItems insertObject:self.openInBarButtonItem atIndex:3];
    }
    
    [self.navigationItem setRightBarButtonItems:rightBarButtonItems animated:YES];
}

- (void)insertCredentialsWithWebView:(UIWebView *)webView
{
    NSString *path = [AMSSettingsFileManager settingsPath];
    NSDictionary *settings = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    NSString* userId = [settings objectForKey:@"canvasUsername"];
    NSString* password =  [settings objectForKey:@"canvasPassword"];
    
    if (userId != nil && password != nil) {
        NSString*  jScriptString1 = [NSString  stringWithFormat:@"document.getElementById('username').value='%@'", userId];
        NSString*  jScriptString2 = [NSString stringWithFormat:@"document.getElementById('password').value='%@'", password];
        
        [webView stringByEvaluatingJavaScriptFromString:jScriptString1];
        [webView stringByEvaluatingJavaScriptFromString:jScriptString2];
        [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('button')[0].click()"];
    }
}

- (void)setCanvasURL
{
    NSString *path = [AMSSettingsFileManager settingsPath];
    NSDictionary *settings = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    NSNumber *indexNumber = [settings objectForKey:@"year"];
    NSUInteger index = [indexNumber integerValue];
    switch (index) {
        case 0:
            self.canvasURL = @"https://canvas.brown.edu/courses/69988";
            break;
        case 1:
            self.canvasURL = @"https://canvas.brown.edu/courses/641699";
            break;
        case 2:
            self.canvasURL = @"https://canvas.brown.edu/courses/801524";
            break;
        case 3:
            self.canvasURL = @"https://canvas.brown.edu/courses/900637";
            break;
        default:
            break;
    }
}


@end
