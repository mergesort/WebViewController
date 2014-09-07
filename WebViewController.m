//
//  JFWebViewController.m
//  Picks
//
//  Created by Joe Fabisevich on 7/22/14.
//  Copyright (c) 2014 Snarkbots. All rights reserved.
//

#import "CustomButtons.h"
#import "WebViewController.h"

#import <PureLayout/PureLayout.h>


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Constants

CGFloat const WebViewControllertoolbarHeight = 44.0f;


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Interface

@interface WebViewController ()
<
    UIScrollViewDelegate
>

@property UIRefreshControl *refreshControl;
@property UIWebView *webView;
@property UIToolbar *toolbar;

@property UIButton *shareButton;

@property UIBarButtonItem *backItem;
@property UIBarButtonItem *forwardItem;

@property NSLayoutConstraint *toolbarBottomConstraint;

@property BOOL viewHasAppeared;

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Implementation

@implementation WebViewController


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle methods

- (void)viewDidLoad
{
    [self commonInit];
    [self load];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];

    if (!self.viewHasAppeared)
    {
        self.viewHasAppeared = YES;
        [self setupConstraints];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Setup

- (void)commonInit
{
    UIColor *backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = backgroundColor;

    _webView = [[UIWebView alloc] init];
    [self.view addSubview:_webView];
    _webView.scalesPageToFit = YES;
    _webView.backgroundColor = backgroundColor;
    _webView.delegate = self;

    _toolbar = [[UIToolbar alloc] init];
    [self.view addSubview:_toolbar];
    _toolbar.translucent = YES;

    BackArrowButton *backButton = [BackArrowButton buttonWithType:UIButtonTypeCustom];
    [backButton autoSetDimensionsToSize:CGSizeMake(50.0f, 30.0f)];
    [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    _backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];

    ForwardArrowButton *forwardButton = [ForwardArrowButton buttonWithType:UIButtonTypeCustom];
    [forwardButton autoSetDimensionsToSize:CGSizeMake(50.0f, 30.0f)];
    [forwardButton addTarget:self action:@selector(goForward) forControlEvents:UIControlEventTouchUpInside];
    _forwardItem = [[UIBarButtonItem alloc] initWithCustomView:forwardButton];

    _shareButton = [ShareButton buttonWithType:UIButtonTypeCustom];
    [_shareButton autoSetDimensionsToSize:CGSizeMake(30.0f, 30.0f)];
    [_shareButton addTarget:self action:@selector(showSharingOptions) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithCustomView:_shareButton];

    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissViewControllerAnimated)];

    UIBarButtonItem *fixedSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpaceItem.width = 5.0f;

    UIBarButtonItem *wideFixedSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    wideFixedSpaceItem.width = 25.0f;

    UIBarButtonItem *flexibleSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    _toolbar.tintColor = lightBlueColor;
    _toolbar.items = @[ fixedSpaceItem, fixedSpaceItem, fixedSpaceItem, fixedSpaceItem, _backItem, fixedSpaceItem, fixedSpaceItem, fixedSpaceItem, fixedSpaceItem, wideFixedSpaceItem, _forwardItem, flexibleSpaceItem, shareItem, wideFixedSpaceItem, doneItem, fixedSpaceItem ];

    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f];
    [self.refreshControl addTarget:self action:@selector(refreshWebView) forControlEvents:UIControlEventValueChanged];
    [self.webView.scrollView addSubview:self.refreshControl];
    self.webView.scrollView.delegate = self;

    [self setBrowserButtonState];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.URL = [NSURL URLWithString:@"http://www.xkcd.com"];
    });
}

- (void)setupConstraints
{
    [_webView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(self.topLayoutGuide.length, 0, 0, 0)];

    self.toolbarBottomConstraint = [_toolbar autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    [_toolbar autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [_toolbar autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [_toolbar autoSetDimension:ALDimensionHeight toSize:WebViewControllertoolbarHeight];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Delegation - UIWebView

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self setBrowserButtonState];
    [self setToolbarVisible:YES];

    if (self.refreshControl.isRefreshing)
    {
        [self.refreshControl endRefreshing];
    }
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Delegation - UIScrollView

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat translation = [scrollView.panGestureRecognizer translationInView:scrollView.superview].y;
    BOOL scrollingUp = (translation > 0.0f);
    [self setToolbarVisible:scrollingUp];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Mutators

- (void)setURL:(NSURL *)URL
{
    _URL = URL;

    if (self.isViewLoaded)
    {
        [self load];
    }
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public methods

- (void)load
{
    if (self.URL)
    {
        NSURLRequest *request = [NSURLRequest requestWithURL:self.URL];
        [self.webView loadRequest:request];
    }
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private methods

- (void)goBack
{
    [self.webView goBack];
}

- (void)goForward
{
    [self.webView goForward];
}

- (void)refreshWebView
{
    [self.webView stopLoading];
    [self.webView reload];
}

- (void)setBrowserButtonState
{
    self.backItem.enabled = [self.webView canGoBack];
    self.forwardItem.enabled = [self.webView canGoForward];
}

- (void)showSharingOptions
{
    if (self.URL)
    {
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[ self.URL ] applicationActivities:nil];
        [self presentViewController:activityViewController animated:YES completion:nil];
    }
}

- (void)dismissViewControllerAnimated
{
    if (self.navigationController)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)setToolbarVisible:(BOOL)visible
{
    self.toolbarBottomConstraint.constant = (visible) ? 0 : WebViewControllertoolbarHeight;

    [UIView animateWithDuration:0.4f delay:0.0f usingSpringWithDamping:0.75f initialSpringVelocity:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}

@end
