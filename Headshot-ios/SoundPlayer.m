//
//  SoundPlayer.m
//
//  Created by Jeffrey Ames on 1/14/13.
//  All rights reserved.
//

#import "SoundPlayer.h"

@interface SoundPlayer() <AVAudioPlayerDelegate>

@end

@implementation SoundPlayer

+ (SoundPlayer *)sharedPlayer
{
    static SoundPlayer *_sharedPlayer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedPlayer = [[SoundPlayer alloc] init];
    });
    return _sharedPlayer;
}

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)vibrate
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

@end
