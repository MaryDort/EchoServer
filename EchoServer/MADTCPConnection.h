//
//  MADTCPConnection.h
//  EchoServer
//
//  Created by Mariia Cherniuk on 05.02.16.
//  Copyright © 2016 marydort. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MADEchoServer;

@interface MADTCPConnection : NSObject {
    @private
    NSInputStream *_readStream;
    NSOutputStream *_writeStream;
}

@property (weak, nonatomic, readwrite) MADEchoServer *server;

- (instancetype)initWithReadStream:(NSInputStream *)readStream
                       writeStream:(NSOutputStream *)writeStream;

- (void)openConnection;
- (void)closeStream;

@end
