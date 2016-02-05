//
//  MADTCPConnection.m
//  EchoServer
//
//  Created by Mariia Cherniuk on 05.02.16.
//  Copyright © 2016 marydort. All rights reserved.
//
#import "MADTCPConnection.h"
#import "MADEchoServer.h"

@interface MADTCPConnection () <NSStreamDelegate>

@end

@implementation MADTCPConnection

- (instancetype)initWithReadStream:(NSInputStream *)readStream
                       writeStream:(NSOutputStream *)writeStream {
    self = [super init];
    
    if (self) {
        _readStream = readStream;
        _writeStream = writeStream;
    }
    
    return self;
}

- (void)openConnection {
    for (NSStream *stream in @[_readStream, _writeStream]) {
        stream.delegate = self;
        [stream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [stream open];
    }
}

- (void)closeStream {
    for (NSStream *stream in @[_readStream, _writeStream]) {
        [stream close];
        [stream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
    _readStream = nil;
    _writeStream = nil;
}

- (void)closeReadStream {
    [_readStream close];
    [_readStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    _readStream = nil;
}

- (void)closeWriteStream {
    [_writeStream close];
    [_writeStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    _writeStream = nil;
}

#pragma mark - NSStreamDelegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    if (eventCode == NSStreamEventOpenCompleted) {
        if ([aStream isKindOfClass:[NSOutputStream class]]) {
            printf("The open outputStream has completed successfully.\n");
        } else {
            printf("The open inputStream has completed successfully.\n");
        }
    } else if (eventCode == NSStreamEventHasBytesAvailable) {
        if (aStream == _readStream) {
            uint8_t buf[BUFSIZ];
            NSInteger len = [_readStream read:buf maxLength:BUFSIZ];
            
            if(len > 0) {
                NSData *echoData = [[NSData alloc] initWithBytes:buf length:len];
                const void *bytes = [echoData bytes];
                
                NSString *data = [[NSString alloc] initWithData:echoData encoding:NSUTF8StringEncoding];
                if ([data isEqualToString:@"disconnect\r\n"]) {
                    [self.server cancelConnection:self];
                } else {
                    [_writeStream write:bytes maxLength:echoData.length];
                }
            } else {
                printf("Failed reading data from stream.");
            }
        }
    } else if (eventCode == NSStreamEventHasSpaceAvailable) {
        if (aStream == _writeStream) {
            NSLog(@"The stream can accept bytes for writing.");
        } else {
            printf("Failed writing data to stream.");
        }
    } else if (eventCode == NSStreamEventErrorOccurred) {
        NSError *error = [aStream streamError];
        
        NSLog(@"%@", error);
        [self.server cancelConnection:self];
    } else if (eventCode == NSStreamEventEndEncountered) {
        [self.server cancelConnection:self];
    } else if (eventCode == NSStreamEventNone) {
        NSLog(@"No event has occurred.");
    }
}

@end
