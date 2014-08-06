//
//  SoundPlayer.h
//
//  Created by Jeffrey Ames on 1/14/13.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface SoundPlayer : NSObject

+ (SoundPlayer *)sharedPlayer;
- (void)vibrate;



@end
