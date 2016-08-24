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
    
    /** Reciving options settings for the plugin **/
    NSString* videoURL = [command argumentAtIndex:0];
    NSDictionary* options = [command argumentAtIndex:1 withDefault:nil];
    
    
    /** Assign callback as self for better managment **/
    self.callbackId = command.callbackId;
    
    /** Verify that an url has been passet to the plugin or redirect with error **/
    if(videoURL == nil){
        [self initError];
    }
    
    
    /** If a video url has been passed **/
    else{
        /** Call the video player open **/
        [self openVideoPlayer:[NSURL URLWithString:videoURL] withOptions:options];
        [self initSuccess];
    }
    
}


- (void)close:(CDVInvokedUrlCommand*)command{
    
    /** Assign callback as self for better managment **/
    self.callbackId = command.callbackId;
    
    [self.AdsVPViewController close];
    
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
        self.AdsVPViewController = [[AdsVPViewController alloc] init: (NSURL*)url withOptions:(NSDictionary*)options];
        self.AdsVPViewController.navigationDelegate = self;
    }
    
    
    // Run later to avoid the "took a long time" log message.
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.AdsVPViewController != nil) {
            [weakSelf.viewController presentViewController:self.AdsVPViewController animated:YES completion:nil];
        }
    });
    
}




/**
 * This method is used to close the video player
 */
- (void)exit
{
    if (self.callbackId != nil) {
        [self exitSuccess];
        self.callbackId = nil;
    }
    self.AdsVPViewController.navigationDelegate = nil;
    self.AdsVPViewController = nil;
}



//Callback actions definitions
- (void)initSuccess
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"EXIT_SUCCESS"];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
}

- (void)exitSuccess
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"INIT_SUCCESS"];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
}


- (void)initError
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"INIT_ERROR"];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
}


- (void)videoEnded
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"VIDEO_ENDED"];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
}

- (void)videoSkip
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"VIDEO_SKIPPED"];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
}

- (void)videoError
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"VIDEO_ERROR"];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
}


- (void)videoStarted
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"VIDEO_STARTED"];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
}

- (void)closeSuccess
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"CLOSE_SUCCESS"];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
}



@end




@interface AdsVPViewController ()
{
    id<NSObject> _timeObserverToken;
}
@end





#pragma mark CDVAdsVPViewController
@implementation AdsVPViewController

/** Set no statusBar for fullscreen **/
- (BOOL)prefersStatusBarHidden {
    return YES;
}


/** Start creating the player view **/
- (id)init: (NSURL*)url withOptions:(NSDictionary*)options
{
    
    self.forceRotation = [options valueForKey:@"forceRotation"];
    self.isSkippable = [[options valueForKey:@"isSkippable"] boolValue];
    self.skippableInSeconds = [[options valueForKey:@"skippableInSeconds"] integerValue];
    
    
    
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
    self.closeButton.hidden = YES;
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
    [self.skipLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    //Creating the video player
    AVPlayer *avPlayer = [[AVPlayer alloc] initWithURL: url];
    self.avPlayerController = [[AVPlayerViewController alloc]init];
    self.avPlayerController.player = avPlayer;
    self.avPlayerController.showsPlaybackControls=NO;
    self.avPlayerController.view.frame = self.view.frame;
    
    //Register listener for player events
    [self.avPlayerController.player addObserver:self forKeyPath:@"status" options:0 context:nil];
    [self.avPlayerController.player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:NULL];
    
    //Attacching elements to the new created player view
    [self.view addSubview:self.avPlayerController.view];
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
    
    return self;
}




- (void)close
{
    
    [self.avPlayerController.player removeObserver:self forKeyPath:@"status"];
    [self.avPlayerController.player removeObserver:self forKeyPath:@"rate"];
    [self.avPlayerController.player pause];
    
    
    if ((self.navigationDelegate != nil) && [self.navigationDelegate respondsToSelector:@selector(exit)]) {
        [self.navigationDelegate exit];
    }
    
    __weak UIViewController* weakSelf = self;
    
    // Run later to avoid the "took a long time" log message.
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([weakSelf respondsToSelector:@selector(presentingViewController)]) {
            [[weakSelf presentingViewController] dismissViewControllerAnimated:YES completion:nil];
        } else {
            [[weakSelf parentViewController] dismissViewControllerAnimated:YES completion:nil];
        }
    });
}





//Listener callback for player status change
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    //check the player init status
    if (object == self.avPlayerController.player && [keyPath isEqualToString:@"status"]) {
        
        [self.navigationDelegate videoStarted];
        
        //If ready to play
        if (self.avPlayerController.player.status == AVPlayerStatusReadyToPlay) {
            
            [self.avPlayerController.player play];
            __weak AdsVPViewController* weakSelf = self;
            
            _timeObserverToken = [self.avPlayerController.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:
                                  ^(CMTime time) {
                                      
                                      if(weakSelf.isSkippable){
                                          
                                          /***** calculate the time skip remaining for change the label text *****/
                                          NSInteger RemainingSkip = (weakSelf.skippableInSeconds - CMTimeGetSeconds(time));
                                          
                                          /***** if the current passing time seconds is more than one second change the label text, not show the 0 seconds... *****/
                                          if(RemainingSkip >= 1 ){
                                              weakSelf.skipLabel.text  = [NSString stringWithFormat:@"Puoi saltare questo video tra %ld", (long) RemainingSkip];
                                          }
                                          
                                          /***** if the current passing time seconds is bigger than the skip time set and the skip is allowed hide the label and show the close button *****/
                                          if(RemainingSkip <= 0 ){
                                              weakSelf.closeButton.hidden = false;
                                              weakSelf.skipLabel.hidden = true;
                                          }
                                          
                                      }
                                      
                                  }];
        }
        
        //if some errors occures
        else if (self.avPlayerController.player.status == AVPlayerStatusFailed) {
            [self.navigationDelegate videoError];
        }
    }
    
    
    
    //check the player playing status
    if (object == self.avPlayerController.player && [keyPath isEqualToString:@"rate"]) {
        float rate = [change[NSKeyValueChangeNewKey] floatValue];
        
        //if the video is stopped
        if (rate == 0.0) {
            
            //if the video is ended
            if (CMTimeGetSeconds(self.avPlayerController.player.currentTime) >= CMTimeGetSeconds(self.avPlayerController.player.currentItem.duration)) {
                [self.navigationDelegate videoEnded];
                self.spinner.hidden = YES;
            }
            //if the video is blocked due to other reasons...
            else{
                self.spinner.hidden = FALSE;
            }
            
        }
        //if the video is playing correctly
        else if (rate == 1.0) {
            self.spinner.hidden = YES;
        }
    }
    
}



/** On Button CLose clicked **/
-(IBAction)btnCloseClicked:(UIButton*)btn
{
    [self.navigationDelegate videoSkip];
}


@end




