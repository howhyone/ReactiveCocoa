//
//  ReactiveCocoaViewController.m
//  ReactiveCocoa
//
//  Created by mob on 2019/3/10.
//  Copyright © 2019年 mob. All rights reserved.
//

#import "ReactiveCocoaViewController.h"

@interface ReactiveCocoaViewController ()
@property (weak, nonatomic) IBOutlet UISlider *rSlider;
@property (weak, nonatomic) IBOutlet UISlider *gSlider;
@property (weak, nonatomic) IBOutlet UISlider *bSlider;
@property (weak, nonatomic) IBOutlet UITextField *rTextField;
@property (weak, nonatomic) IBOutlet UITextField *gTextField;
@property (weak, nonatomic) IBOutlet UITextField *bTextField;
@property (weak, nonatomic) IBOutlet UIView *colorView;

@end

@implementation ReactiveCocoaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    ReactiveCocoaViewController *reactiveCocoaVC = [[ReactiveCocoaViewController alloc] initWithNibName:@"ReactiveCocoaViewController" bundle:nil];
    _rTextField.text = _gTextField.text = _bTextField.text = @"0.5";
    RACSignal *rSignal = [self blindSlider:_rSlider textField:_rTextField];
    RACSignal *gSignal = [self blindSlider:_gSlider textField:_gTextField];
    RACSignal *bSignal = [self blindSlider:_bSlider textField:_bTextField];
    [[[RACSignal combineLatest:@[rSignal,gSignal,bSignal]] map:^id(id value) {
        return [UIColor colorWithRed:[value[0] floatValue] green:[value[1] floatValue] blue:[value[2] floatValue] alpha:1];
    }] subscribeNext:^(id x) {
        self->_colorView.backgroundColor = x;
    }];
}

-(RACSignal *)blindSlider:(UISlider *)slider textField:(UITextField *)textField
{
    RACChannelTerminal *signalSlider = [slider rac_newValueChannelWithNilValue:nil];
    RACChannelTerminal *signalText = [textField rac_newTextChannel];
    [[signalSlider map:^id(id value) {
        return [NSString stringWithFormat:@"%.02f",[value floatValue]];
    }]subscribe:signalText];
    [signalText subscribe:signalSlider];
    RACSignal *textSignal = [[textField rac_textSignal] take:1];
    return [[signalText merge:signalSlider] merge:textSignal];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
