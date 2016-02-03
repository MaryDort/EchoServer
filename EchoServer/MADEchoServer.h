//
//  MADEchoServer.h
//  EchoServer
//
//  Created by Mariia Cherniuk on 02.02.16.
//  Copyright © 2016 marydort. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MADEchoServer : NSObject

@property (assign, nonatomic, readwrite) NSInteger port;
@property (assign, nonatomic, readonly, getter = isRunning) BOOL running;

- (instancetype)initWithPort:(NSInteger)port;

- (void)start;
- (void)stop;

@end


@interface MADInvalidPortException : NSException
@end


@interface MADNotOpetWriteStreamException : NSException
@end


@interface MADSocketException : NSException
@end

