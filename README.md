<!--
# license: Licensed to the Apache Software Foundation (ASF) under one
#         or more contributor license agreements.  See the NOTICE file
#         distributed with this work for additional information
#         regarding copyright ownership.  The ASF licenses this file
#         to you under the Apache License, Version 2.0 (the
#         "License"); you may not use this file except in compliance
#         with the License.  You may obtain a copy of the License at
#
#           http://www.apache.org/licenses/LICENSE-2.0
#
#         Unless required by applicable law or agreed to in writing,
#         software distributed under the License is distributed on an
#         "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#         KIND, either express or implied.  See the License for the
#         specific language governing permissions and limitations
#         under the License.
-->

# cordova-plugin-adsvp

You can play a video withouts controls for the user with a timer for force the user see the video.

This plugin provides a the access to the player using `cordova.plugins.AdsVP.play()`

    cordova.plugins.AdsVP.play( "http://myvideo.com/video.mp4,
        successCallback,
        errorCallback,
        {
            "forceRotation" : "landscape",
            "isSkippable" : true,
            "skippableInSeconds" : 15,
        }
    );


The successCallback always return a status that can be one of the follow:

INIT_SUCCESS: Video has been initizalized
VIDEO_STARTED: Video is begin playing
VIDEO_ENDED: Video has terminated
VIDEO_SKIPPED: The user has click on close button before the video end

