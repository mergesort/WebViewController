//
//  JFWebViewController.h
//  Picks
//
//  Created by Joe Fabisevich on 7/22/14.
//  Copyright (c) 2014 Snarkbots. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebViewController : UIViewController
<
    UIWebViewDelegate
>

//If you set the URL while the WebViewController is loaded, it will load the URL
@property (nonatomic) NSURL *URL;

@end
