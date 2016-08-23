/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import <Cordova/CDVPlugin.h>
#import <Cordova/CDVInvokedUrlCommand.h>
#import <Cordova/CDVScreenOrientationDelegate.h>

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@import AVKit;

@class AdsVPViewController;



@interface AdsVP : CDVPlugin {}
@property (nonatomic, retain) AdsVPViewController* AdsVPViewController;
@property (nonatomic, copy) NSString* callbackId;
- (void)play:(CDVInvokedUrlCommand*)command;
@end



@interface AdsVPViewController : UIViewController <UIWebViewDelegate, CDVScreenOrientationDelegate>{}
/** Define the view that will be used to display the player **/
@property (nonatomic, strong) IBOutlet AVPlayerViewController* avPlayerController;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* spinner;
@property (nonatomic, strong) IBOutlet UIButton* closeButton;
@property (nonatomic, strong) IBOutlet UILabel * skipLabel;
@property AVURLAsset *asset;


/** Implementation of the player */
@property (nonatomic, strong) IBOutlet AVPlayerItem * avPlayerItem;
@property (nonatomic, strong) IBOutlet AVPlayer * avPlayer;
@property (nonatomic, strong) IBOutlet AVPlayerLayer * avPlayerLayer;
@property (nonatomic, weak) AdsVP* navigationDelegate;

/** Avaiable method in the view **/
- (id)init: (NSDictionary*) options;
@end




@interface AdsVPNavigationController : UINavigationController
@property (nonatomic, weak) id <CDVScreenOrientationDelegate> orientationDelegate;
@end
