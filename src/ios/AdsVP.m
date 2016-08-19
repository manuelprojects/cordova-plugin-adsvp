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

#import "AdsVP.h"
#import <Cordova/CDVPluginResult.h>

@import Foundation;
@import AVFoundation;
@import CoreMedia.CMTime;
@import AVKit;

#pragma mark CDVAdsVP
@implementation AdsVP


/**
 * This method is used to show the player and begin the play
 */
- (void)play:(CDVInvokedUrlCommand*)command{
    
    /**Creating plugin result object **/
    CDVPluginResult* pluginResult;
    
    /** Reciving options settings for the plugin **/
    NSString* videoURL = [command argumentAtIndex:0];
    NSDictionary* options = [command argumentAtIndex:1];
    
    
    /** Assign callback as self for better managment **/
    self.callbackId = command.callbackId;
    
    /** Verify that an url has been passet to the plugin or redirect with error **/
    if(videoURL == nil){
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"incorrect number of arguments"];
    }
    
    
    /** If a video url has been passed **/
    else{
        
        /** Call the video player open **/
        [self openVideoPlayer:[NSURL URLWithString:videoURL] withOptions:options];
        
        /** Create plugin result as video started **/
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        
    }
    
    
    /** Set keep callback for futures possible callbacks **/
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    
    /** Return the callback */
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}




/**
 * This method is used to initizialize and open the video player
 */
- (void)openVideoPlayer:(NSURL*)url withOptions:(NSDictionary*)options
{
    
    
    __weak AdsVP* weakSelf = self;
    
    
    /** If is the first time that we initizalize the Video Player **/
    if (self.AdsVPViewController == nil) {
        
        /** call the initialization of the player **/
        self.AdsVPViewController = [[AdsVPViewController alloc] init: options];
    }
    
    
    // Run later to avoid the "took a long time" log message.
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.AdsVPViewController != nil) {
            [weakSelf.viewController presentViewController:self.AdsVPViewController animated:YES completion:nil];
        }
    });
    
    
}

@end







#pragma mark CDVAdsVPViewController
@implementation AdsVPViewController


- (id)init: (NSDictionary*) options
{
    self = [super init];
    if (self != nil){ [self createViews]; }
    return self;
}




/** Set no statusBar for fullscreen **/
- (BOOL)prefersStatusBarHidden {
    return YES;
}




/** Start creating the player view **/
- (void)createViews
{
    
    /** Creating the link to the boundle used **/
    NSBundle* AdsVPBundle = [NSBundle bundleForClass:[AdsVP class]];
    
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor blackColor];
    
    /** Create View elements Configure the spinner **/
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinner.alpha = 1.000;
    self.spinner.clearsContextBeforeDrawing = NO;
    self.spinner.contentMode = UIViewContentModeScaleToFill;
    self.spinner.hidden = NO;
    self.spinner.hidesWhenStopped = YES;
    self.spinner.multipleTouchEnabled = NO;
    self.spinner.opaque = NO;
    self.spinner.userInteractionEnabled = NO;
    [self.spinner setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.spinner startAnimating];
    
    
    //Creating the close button
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeButton.frame = CGRectMake(0, 0, 40.0, 40.0);
    UIImage* closeButtonImage = [UIImage imageNamed:@"AdsVP.bundle/CloseButton" inBundle:AdsVPBundle compatibleWithTraitCollection:nil];
    [self.closeButton setImage:closeButtonImage forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(btnCloseClicked:)forControlEvents:UIControlEventTouchUpInside];
    [self.closeButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    
    //Creating the skiplabel
    self.skipLabel = [[UILabel alloc] init];
    self.skipLabel.frame = CGRectMake(0, 0, 40.0, 40.0);
    self.skipLabel.backgroundColor=[UIColor clearColor];
    self.skipLabel.textColor=[UIColor whiteColor];
    self.skipLabel.userInteractionEnabled=FALSE;
    self.skipLabel.font=[self.skipLabel.font fontWithSize:12];
    self.skipLabel.text= @"Puoi saltare questo video tra x secondi";
    [self.skipLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    
    //Creating the video player
    NSURL *url = [NSURL URLWithString:@"https://www.peer5.com/media/bay_bridge.mp4"];
    AVPlayer *avPlayer = [[AVPlayer alloc] initWithURL: url];
    AVPlayerViewController *avPlayerController = [[AVPlayerViewController alloc]init];
    avPlayerController.player = avPlayer;
    avPlayerController.showsPlaybackControls=NO;
    avPlayerController.view.frame = self.view.frame;
    
    
    
    
    //Attacching elements to the new created player view
    [self.view addSubview:avPlayerController.view];
    [self.view addSubview:self.closeButton];
    [self.view addSubview:self.skipLabel];
    [self.view addSubview:self.spinner];
    
    
    // Spinner Placement
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.spinner
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1.0
                              constant:0.0
                              ]
     ];
    
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.spinner
                              attribute:NSLayoutAttributeCenterY
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterY
                              multiplier:1.0 constant:0.0
                              ]
     ];
    
    
    
    
    
    // Close Button Placement
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.closeButton
                              attribute:NSLayoutAttributeRight
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeRight
                              multiplier:1.0
                              constant:-10
                              ]
     ];
    
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.closeButton
                              attribute:NSLayoutAttributeTop
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeTop
                              multiplier:1.0 constant:10
                              ]
     ];
    
    
    
    
    // Text Label Placement
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.skipLabel
                              attribute:NSLayoutAttributeBottom
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeBottom
                              multiplier:1.0
                              constant:-10
                              ]
     ];
    
    // Text Label Placement
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.skipLabel
                              attribute:NSLayoutAttributeLeft
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeLeft
                              multiplier:1.0
                              constant:10
                              ]
     ];
    
    
    
}


- (void) viewDidAppear:(BOOL) animated {
    [self.avPlayer play];
    [super viewDidAppear:animated];
}




/** On Button CLose clicked **/
-(IBAction)btnCloseClicked:(UIButton*)btn
{
    NSLog(@"button tapped");
}

@end




