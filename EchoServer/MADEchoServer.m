//
//  MADEchoServer.m
//  EchoServer
//
//  Created by Mariia Cherniuk on 02.02.16.
//  Copyright © 2016 marydort. All rights reserved.
//

#import "MADEchoServer.h"
#import <CoreFoundation/CoreFoundation.h>
#import <sys/socket.h>
#import <netinet/in.h>
#define DEFAULT_PORT 80
#define MAX_PORT 65535

@interface MADEchoServer ()

@property (retain, nonatomic, readonly) NSInputStream *inputStream;
@property (retain, nonatomic, readonly) NSOutputStream *outputStream;
@property (assign, nonatomic, readonly) CFSocketRef ipv4Socket;

@end

@implementation MADEchoServer

- (instancetype)init {
    self = [super init];
    
    if (self) {
        CFReadStreamRef readStream;
        CFWriteStreamRef writeStream;
        
        CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"localhost", (UInt32)DEFAULT_PORT, &readStream, &writeStream);
        if(!CFWriteStreamOpen(writeStream)) {
            @throw [[[MADNotOpetWriteStreamException alloc] initWithName:@"MADNotOpetWriteStreamException"
                                                                  reason:@"WriteStream not open."
                                                                userInfo:nil] autorelease];
        }
        _inputStream = [(NSInputStream *)read retain];
        _outputStream = [(NSOutputStream *)write retain];
        _ipv4Socket = 0;
        _port = DEFAULT_PORT;
        _running = NO;
    }
    
    return self;
}

- (instancetype)initWithPort:(NSInteger)port {
    self = [super init];
    
    if (self) {
        if (port > 65535 || port < 1) {
            @throw [[[MADInvalidPortException alloc] initWithName:@"MADInvalidPortException"
                                                           reason:@"65535 < port value > 1"
                                                         userInfo:nil] autorelease];
        }
        CFReadStreamRef readStream;
        CFWriteStreamRef writeStream;
        
        CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"localhost", (UInt32)port, &readStream, &writeStream);
        if(!CFWriteStreamOpen(writeStream)) {
            @throw [[[MADNotOpetWriteStreamException alloc] initWithName:@"MADNotOpetWriteStreamException"
                                                                 reason:@"WriteStream not open."
                                                               userInfo:nil] autorelease];
        }
        _inputStream = [(NSInputStream *)read retain];
        _outputStream = [(NSOutputStream *)write retain];
        _ipv4Socket = 0;
        _port = port;
        _running = NO;
    }
    
    return self;
}

- (void)dealloc {
    [_inputStream release];
    [_outputStream release];
    [super dealloc];
}

- (void)start {
    //    Старт должен создать сокет и слушать.
    [self openSocket];
    [self listen];
}

//close socket
- (void)stop {
    CFSocketInvalidate(_ipv4Socket);
    CFRelease(_ipv4Socket);
    _ipv4Socket = nil;
}

- (void)openStream {
    for (NSStream *stream in @[_inputStream, _outputStream]) {
        [stream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [stream open];
    }
}

- (void)closeStream {
    for (NSStream *stream in @[_inputStream, _outputStream]) {
        [stream close];
        [stream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        stream = nil;
    }
}

//void collBack(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {
//    
//}
//



//    opening a socket to listen for TCP connections
- (void)openSocket {
    //    створюємо сокет сервера як TCP IPv4
    CFSocketContext socketContext = { 0, self, NULL, NULL, NULL };
    _ipv4Socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, NULL, &socketContext);
    
    if (!_ipv4Socket) {
        @throw [[[MADSocketException alloc] initWithName:@"MADSocketException"
                                                  reason:@"Unable to create socket."
                                                userInfo:nil] autorelease];
    }
    
    //    встановлюємо порт і адресу, які збираємось слухати
    struct sockaddr_in socketAddress;
    memset(&socketAddress, 0, sizeof(socketAddress));
    
    socketAddress.sin_len = sizeof(socketAddress);
    socketAddress.sin_family = AF_INET;
    socketAddress.sin_port = htons(_port);
    socketAddress.sin_addr.s_addr = htonl(INADDR_ANY);
    
    CFDataRef addressData = CFDataCreate(kCFAllocatorDefault, (UInt8 *)&socketAddress, sizeof(socketAddress));
    
    if (CFSocketSetAddress(_ipv4Socket, addressData) != kCFSocketSuccess) {
        @throw [[[MADSocketException alloc] initWithName:@"MADSocketException"
                                                  reason:@"Unable to bind socket to address."
                                                userInfo:nil] autorelease];
    }
    CFRelease(addressData);
}

//    Begin listening on a socket
- (void)listen {
    CFRunLoopSourceRef socketSource = CFSocketCreateRunLoopSource(kCFAllocatorDefault, _ipv4Socket, 0);
    
    CFRunLoopAddSource(CFRunLoopGetCurrent(), socketSource, kCFRunLoopCommonModes);
    CFRelease(socketSource);
    NSLog(@"Socket listening on port %ld\n", (long)_port);
}

@end


@implementation MADInvalidPortException
@end


@implementation MADNotOpetWriteStreamException
@end


@implementation MADSocketException
@end

