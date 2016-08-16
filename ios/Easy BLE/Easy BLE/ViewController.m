//
//  ViewController.m
//  Easy BLE
//
// Copyright (c) 2013 Alicia M. F. Key
//
// The MIT License (MIT)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "ViewController.h"
#import "BLEDefines.h"
#import "GadgetController.h"

#define NO_VALUE_STRING @"----"

@interface ViewController ()

// Properties for controlling the UI
@property (weak, nonatomic) IBOutlet UISwitch *onOrOffToggle;
@property (weak, nonatomic) IBOutlet UILabel *onOrOffToggleLabel;
@property (weak, nonatomic) IBOutlet UILabel *peripheralControlLabel;
@property (weak, nonatomic) IBOutlet UILabel *motorSpeedLabel;
@property (weak, nonatomic) IBOutlet UISlider *motorSpeedSlider;
@property (weak, nonatomic) IBOutlet UIButton *disconnectButton;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UILabel *rssiLabel;
@property (weak, nonatomic) IBOutlet UILabel *analogLabel;
@property (weak, nonatomic) IBOutlet UILabel *rssiValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *analogValueLabel;

// Property for handling the GadgetController
@property (strong) GadgetController *gadget;

@end

@implementation ViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [[self disconnectButton] setAlpha:0.5];
    GadgetController *innerGadget = [[GadgetController alloc] init];
    [innerGadget setDelegate:self];
    [self setGadget:innerGadget];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Handle UI Controls

-(IBAction)ledOnOrOffToggled:(id)sender {
    [_gadget toggleLEDStateTo:[[self onOrOffToggle] isOn]];
}

-(IBAction)connectButtonClicked:(id)sender {
    //NSLog(@"Connect button clicked...");
    [_gadget connectGadget];
}

-(IBAction)disconnectButtonClicked:(id)sender {
    //NSLog(@"Disconnect button clicked.");
    [_gadget disconnectGadget];
}

-(IBAction)motorSpeedChanged:(id)sender {
    float value = [[self motorSpeedSlider] value];
    [_gadget updateMotorSpeedTo:value];
    //NSLog(@"Motor speed changed: %f", value);
}

#pragma mark - The GadgetController delegate methods.
// See the GadgetControllerDelegate.h file for an explanation of these methods in comments

-(void)gadgetDidConnect {
    //NSLog(@"The gadget did CONNECT");
    [[self rssiLabel] setEnabled:YES];
    [[self rssiValueLabel] setEnabled:YES];
    [[self analogLabel] setEnabled:YES];
    [[self analogValueLabel] setEnabled:YES];
    [[self onOrOffToggle] setEnabled:YES];
    [[self onOrOffToggleLabel] setEnabled:YES];
    [[self peripheralControlLabel] setEnabled:YES];
    [[self motorSpeedLabel] setEnabled:YES];
    [[self motorSpeedSlider] setEnabled:YES];
    [[self connectButton] setEnabled:NO];
    [[self connectButton] setAlpha:0.5];
    [[self disconnectButton] setEnabled:YES];
    [[self disconnectButton] setAlpha:1.0];
}

-(void)gadgetDidDisconnect {
    //NSLog(@"The gadget did disconnect");
    [[self rssiLabel] setEnabled:NO];
    [[self rssiValueLabel] setEnabled:NO];
    [[self analogLabel] setEnabled:NO];
    [[self analogValueLabel] setEnabled:NO];
    [[self onOrOffToggle] setEnabled:NO];
    [[self onOrOffToggleLabel] setEnabled:NO];
    [[self peripheralControlLabel] setEnabled:NO];
    [[self motorSpeedLabel] setEnabled:NO];
    [[self motorSpeedSlider] setEnabled:NO];
    [[self connectButton] setEnabled:YES];
    [[self connectButton] setAlpha:1.0];
    [[self disconnectButton] setEnabled:NO];
    [[self disconnectButton] setAlpha:0.5];
    [[self rssiValueLabel] setText:NO_VALUE_STRING];
    [[self analogValueLabel] setText:NO_VALUE_STRING];
    [[self onOrOffToggle] setOn:NO];
    [[self motorSpeedSlider] setValue:0.0f];
}

-(void)gadgetAnalogReadDidUpdateValue:(CGFloat)percent {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *valueLabel = [NSString stringWithFormat:@"%2.1f%%", percent*100];
        [[self analogValueLabel] setText:valueLabel];
    });
}

-(void)gadgetDidUpdateRSSI:(NSNumber *)rssi {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self rssiValueLabel] setText:[NSString stringWithFormat:@"%@", rssi]];
    });
}

@end
