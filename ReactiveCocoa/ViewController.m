//
//  ViewController.m
//  ReactiveCocoa
//
//  Created by mob on 2019/3/10.
//  Copyright © 2019年 mob. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self signal];
//    [self subject];
//    [self replaySubject];
//    [self dicTuple];
//    [self multicastConnection];
    [self command];
}

-(void)signal
{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@1];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"默认信号发送完毕被取消");
        }];
    }];
    
    RACDisposable *disposable = [signal subscribeNext:^(id x) {
        NSLog(@"---%@",x);
    }];
    [disposable dispose];
}

-(void)subject
{
    RACSubject *subject = [RACSubject subject];
    [subject subscribeNext:^(id x) {
        NSLog(@"订阅者---%@",x);
    }];
    [subject subscribeNext:^(id x) {
        NSLog(@"订阅者 --- %@",x);
    }];
    [subject sendNext:@"111"];
}

-(void)replaySubject
{
    RACReplaySubject *replaySubject = [RACReplaySubject subject];
    [replaySubject sendNext:@"1111"];
    [replaySubject sendNext:@"222"];
    [replaySubject
     subscribeNext:^(id x) {
         NSLog(@"第一个订阅者%@",x);
     }];
    [replaySubject subscribeNext:^(id x) {
        NSLog(@"第二个订阅者%@",x);
    }];
}

-(void)dicTuple
{
    NSDictionary *dict = @{@"name":@"张旭",@"age":@"20",@"sex":@"男"};
    [dict.rac_sequence.signal subscribeNext:^(id x) {
        RACTupleUnpack(NSString *key,NSString *value) = x;
        NSLog(@"%@-------%@",key,value);
//        NSString *key = x[0];
//        NSString *value = x[1];
    }];
}

-(void)multicastConnection
{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"请求一次");
        [subscriber sendNext:@"2"];
        return nil;
    }];
    RACMulticastConnection *connection = [signal publish];
    [connection.signal subscribeNext:^(id x) {
        NSLog(@"第一个订阅者%@",x);
    }];
    [connection.signal subscribeNext:^(id x) {
        NSLog(@"第二个订阅者%@",x);
    }];
    [connection.signal subscribeNext:^(id x) {
        NSLog(@"第三个订阅者%@",x);
    }];
    [connection connect];
}

-(void)command
{
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        NSLog(@"input ======= %@",input);
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSLog(@"发布数据");
            [subscriber sendNext:@"22"];
            [subscriber sendCompleted];
            return nil;
        }];
    }];
    [command.executionSignals.switchToLatest subscribeNext:^(id x) {
        NSLog(@"拿到信号的方式=%@",x);
    }];
    RACSignal *signal = [command execute:@"11"];
    [signal subscribeNext:^(id x) {
        NSLog(@"d拿到信号的方式一%@",x);
    }];
    [command execute:@"11"];
    [command.executing subscribeNext:^(id x) {
        if ([x boolValue] == YES) {
            NSLog(@"命令正在执行");
        }
        else{
            NSLog(@"命令m完成/没有执行");
        }
    }];
}
@end
