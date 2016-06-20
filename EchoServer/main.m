//
//  main.m
//  EchoServer
//
//  Created by Mariia Cherniuk on 02.02.16.
//  Copyright © 2016 marydort. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MADEchoServer.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
//        MADEchoServer *server = [[MADEchoServer alloc] init];
//        NSLog(@"%hhu", server.isRunning);
//        NSLog(@"%ld", server.port);
//        
//        [server start];
//        NSLog(@"%hhu", server.isRunning);
//        [server stop];
//        NSLog(@"%hhu", server.isRunning);
//
        MADEchoServer *server = [[MADEchoServer alloc] initWithPort:54321];
        NSLog(@"%ld", server.port);
        NSLog(@"%hhu", server.isRunning);
        [server start];
        NSLog(@"%hhu", server.isRunning);

        [[NSRunLoop currentRunLoop] run];
    }
    return 0;
}
