//
//  AudioQueuePlayer.m
//  TuSDKVEDemo
//
//  Created by 刘鹏程 on 2021/8/17.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

#import "AudioQueuePlayer.h"
#import "XBEchoCancellation.h"

@interface AudioQueuePlayer()

@property (nonatomic,strong) NSData *dataStore;

@end

@implementation AudioQueuePlayer

UInt32 _readerLength;

+ (instancetype)shared
{
    static AudioQueuePlayer *player = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        player = [[AudioQueuePlayer alloc] init];
    });
    return player;
}


- (void)playerWithFilePath:(NSString *)filePath
{
    self.dataStore = [NSData dataWithContentsOfFile:filePath];
    [[XBEchoCancellation shared] stopInput];
    _readerLength = 0;
    
    typeof(self) __weak weakSelf = self;
    
    if ([XBEchoCancellation shared].bl_output == nil) {
        
        [XBEchoCancellation shared].bl_output = ^(AudioBufferList *bufferList, UInt32 inNumberFrames) {
            AudioBuffer buffer = bufferList->mBuffers[0];
            
            int len = readData(buffer.mData, buffer.mDataByteSize,weakSelf.dataStore);
            buffer.mDataByteSize = len;
            
            if (len == 0)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf stopOutPut];
                });
            } else {
                
            }
        };
    }
    
    [[XBEchoCancellation shared] startOutput];
}

- (void)stopOutPut
{
    [[XBEchoCancellation shared] stopOutput];
}

int readData(Byte *data, int len, NSData *dataStore)
{
    UInt32 currentReadLength = 0;
    
    if (_readerLength >= dataStore.length)
    {
        _readerLength = 0;
        return currentReadLength;
    }
    if (_readerLength+ len <= dataStore.length)
    {
        _readerLength = _readerLength + len;
        currentReadLength = len;
    }
    else
    {
        currentReadLength = (UInt32)(dataStore.length - _readerLength);
        _readerLength = (UInt32) dataStore.length;
    }
    
    NSData *subData = [dataStore subdataWithRange:NSMakeRange(_readerLength, currentReadLength)];
    Byte *tempByte = (Byte *)[subData bytes];
    memcpy(data,tempByte,currentReadLength);
    
    
    return currentReadLength;
}


@end
