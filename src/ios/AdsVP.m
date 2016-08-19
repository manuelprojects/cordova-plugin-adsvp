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
        
        // We create the views in code for primarily for ease of upgrades and not requiring an external .xib to be included
        CGRect playerViewBounds = self.view.bounds;
        
        self.playerView = [[UIView alloc] initWithFrame:playerViewBounds];
        
        [self.view addSubview:self.playerView];
        [self.view sendSubviewToBack:self.playerView];
        
        
        /** Configure the view  **/
        self.playerView.backgroundColor = [UIColor blackColor];
        
        /** Configure the spinner **/
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.spinner.alpha = 1.000;
        self.spinner.autoresizesSubviews = YES;
        self.spinner.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin);
        self.spinner.clearsContextBeforeDrawing = NO;
        self.spinner.clipsToBounds = NO;
        self.spinner.contentMode = UIViewContentModeScaleToFill;
        self.spinner.frame =  CGRectMake(round((self.playerView.frame.size.width - 25) / 2), round((self.playerView.frame.size.height - 25) / 2), 25, 25);
        self.spinner.hidden = NO;
        self.spinner.hidesWhenStopped = YES;
        self.spinner.multipleTouchEnabled = NO;
        self.spinner.opaque = NO;
        self.spinner.userInteractionEnabled = NO;
        [self.spinner startAnimating];
        
        /** Creating the close button **/
        self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.closeButton.frame = CGRectMake(self.playerView.frame.size.width - 40, 0.0, 40, 40);
        self.closeButton.autoresizesSubviews = YES;
        self.closeButton.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin);
        UIImage* closeButtonImage = [UIImage imageNamed:@"AdsVP.bundle/CloseButton" inBundle:AdsVPBundle compatibleWithTraitCollection:nil];
        [self.closeButton setImage:closeButtonImage forState:UIControlStateNormal];
        [self.closeButton addTarget:self action:@selector(btnCloseClicked:)forControlEvents:UIControlEventTouchUpInside];
        
        
        /** Creating the skiplabel **/
        self.skipLabel = [[UILabel alloc] init];
        self.skipLabel.frame = CGRectMake(self.playerView.frame.size.width - 40, self.playerView.frame.size.height - 40, 0, 0);
        self.skipLabel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin);
        self.skipLabel.backgroundColor=[UIColor clearColor];
        self.skipLabel.textColor=[UIColor whiteColor];
        self.skipLabel.userInteractionEnabled=YES;
        self.skipLabel.text= @"Puoi saltare questo video tra x secondi";
        
        
        /**Creating the video player */
        NSURL *fileURL = [NSURL fileURLWithPath:@"http://clips.vorwaerts-gmbh.de/VfE_html5.mp4"];
        self.avPlayerItem = [AVPlayerItem playerItemWithURL:fileURL];
        self.avPlayer = [AVPlayer playerWithPlayerItem:self.avPlayerItem];
        self.avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
        self.avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.avPlayerLayer.frame = self.view.bounds;
        
        
        
        /** Attacching elements to the view **/
        [self.view addSubview:self.spinner];
        [self.view addSubview:self.closeButton];
        [self.view addSubview:self.skipLabel];
        
        
        [self.playerView.layer addSublayer:self.avPlayerLayer];
        [self.avPlayer play];
        
        
        
        
        
    }


    - (void)start
    {
        
    }




    /** On Button CLose clicked **/
    -(IBAction)btnCloseClicked:(UIButton*)btn
    {
        NSLog(@"button tapped");
    }

@end




