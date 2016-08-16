//
//  GadgetController.m
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

#import "GadgetController.h"
#import "GadgetControllerDelegate.h"
#import "BLEDefines.h"

@interface GadgetController ()

// Properties for controlling the Bluetooth communications
@property (strong) CBCentralManager *theCBCentralManager;
@property (strong) CBPeripheral *thePeripheral;

// Properties for holding the characterisitics when they are discovered 
@property (strong) NSMutableArray *writableCharacterisitics;
@property (strong) NSMutableArray *notifyingCharacterisitics;
@property (strong) NSMutableArray *readableCharacterisitics;
@property (strong) NSMutableArray *allCharacterisitics;

@end

@implementation GadgetController

#pragma mark - Instantiation

-(id)init {
    [self setTheCBCentralManager:[[CBCentralManager alloc] initWithDelegate:self queue:nil]];
    return self;
}

#pragma mark - CoreBluetooth (2 of 4) Discover Peripherals

-(void)connectGadget {
    [[self theCBCentralManager] scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@BLE_DEVICE_SERVICE_UUID]] options:nil];
    return;
}

-(void)disconnectGadget {
    if ([self thePeripheral] != nil) {
        [[self theCBCentralManager] cancelPeripheralConnection:[self thePeripheral]];
    } else {
        NSLog(@"ERROR! No gadget connected, will not disconnect.");
    }
}

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    //NSLog(@"didDisconnectPeripheral: called %@", error);
    [self postDisconnect];
}

// After disconnection, there are some takedown tasks for both this instance and its delegate. These are done here.
-(void)postDisconnect {
    [[self delegate] gadgetDidDisconnect];
    [self setThePeripheral:nil];
    [self setWritableCharacterisitics:nil];
    [self setReadableCharacterisitics:nil];
    [self setNotifyingCharacterisitics:nil];
    [self setAllCharacterisitics:nil];
}

-(void)centralManagerDidUpdateState:(CBCentralManager *)central {

    return;
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    [self setThePeripheral:peripheral];
    [[self theCBCentralManager] stopScan];
    [[self theCBCentralManager] connectPeripheral:peripheral options:[NSDictionary dictionaryWithObject:@0 forKey:CBConnectPeripheralOptionNotifyOnConnectionKey]];
    return;
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    [peripheral setDelegate:self];
    [self preServiceDiscovery];
    [peripheral discoverServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@BLE_DEVICE_SERVICE_UUID]]];
    return;
}

#pragma mark - CoreBluetooth (3 of 4) Discover services and characteristics

// Before the service discovery, the arrays must be setup to hold the characterisitics that will be discovered
-(void)preServiceDiscovery {
    [self setWritableCharacterisitics:[NSMutableArray arrayWithCapacity:10]];
    [self setNotifyingCharacterisitics:[NSMutableArray arrayWithCapacity:10]];
    [self setReadableCharacterisitics:[NSMutableArray arrayWithCapacity:10]];
    [self setAllCharacterisitics:[NSMutableArray arrayWithCapacity:30]];
}

// Discover all services for the first service (experimentally determined via reverse engineering)
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    [peripheral discoverCharacteristics:nil forService:[peripheral services][0]];
    return;
}

// This sorts out characterisitics with various properties from the given service.
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    //NSLog(@"didDiscoverCharacteristicsForService found %d characterisitics and UUID %@", [[service characteristics] count], [service UUID]);
   
    [[service characteristics] enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        
        CBCharacteristic *characteristic = (CBCharacteristic *)obj;
        [[self allCharacterisitics] addObject:characteristic];
        
        if ([characteristic properties] == CBCharacteristicPropertyWriteWithoutResponse) {
            //NSLog(@"characterisitic %d: CBCharacteristicPropertyWriteWithoutResponse, UUID = %@", [characteristic properties], [characteristic UUID]);
            [[self writableCharacterisitics] addObject:characteristic];
        
        } else if ([characteristic properties] == CBCharacteristicPropertyRead) {
            //NSLog(@"characterisitic %d: CBCharacteristicPropertyRead, UUID = %@", [characteristic properties], [characteristic UUID]);
            [[self readableCharacterisitics] addObject:characteristic];
        
        } else if ([characteristic properties] == CBCharacteristicPropertyNotify) {
            //NSLog(@"characterisitic %d: CBCharacteristicPropertyNotify, UUID = %@", [characteristic properties], [characteristic UUID]);
            [[self notifyingCharacterisitics] addObject:characteristic];
        
        } else {
            //NSLog(@"characterisitic %d: unknown property, UUID = %@", [characteristic properties], [characteristic UUID]);
        }
        
    }];
    [self postCharacteristicDiscovery];
    return;
}

// After all the characteristics are discovered, there are a few tasks to prepare the the controller for operation. These tasks are in this method
-(void)postCharacteristicDiscovery {
    [self startAnalogUpdates];
    [self requestAllNotifyingCharacteristics];
    [[self delegate] gadgetDidConnect];
    [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(readCurrentRSSI:) userInfo:nil repeats:YES];
    
     // In order to actually make the BLE Shield send something, after 1/2 second, send the reset request.
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self resetRX];
    });
}

-(void)requestAllNotifyingCharacteristics {
    [[self notifyingCharacterisitics] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CBCharacteristic *characteristic = (CBCharacteristic *)obj;
        [[self thePeripheral] setNotifyValue:YES forCharacteristic:characteristic];
    }];
}

#pragma mark - CoreBluetooth (4 of 4) Read from and write to characterisitics and RSSI

// This is called by an NSTimer to continuously update the RSSI value on the user interface.
-(void)readCurrentRSSI:(NSTimer *)theTimer {
    if ([self thePeripheral] != nil) {
        [[self thePeripheral] readRSSI];
    } else {
        [theTimer invalidate];
    }
}

-(void)updateMotorSpeedTo:(float)speedFromUI {
    static const NSUInteger MOTOR_WRITABLE_CHARACTERISITIC_INDEX = 0;
    CBCharacteristic *writeToMe = [[self writableCharacterisitics] objectAtIndex:MOTOR_WRITABLE_CHARACTERISITIC_INDEX];
    static UInt8 minSpeedForMotor = 100;
    static UInt8 maxAmountUpForMotor = 150;
    UInt8 speedToSendToMotor = 0;
    
    if (speedFromUI == 0.0) {
        speedToSendToMotor = 0;
    } else {
        speedToSendToMotor = minSpeedForMotor + (UInt8)((float)maxAmountUpForMotor * speedFromUI);
    }
    
    UInt8 buffer[3] = {0x02, speedToSendToMotor, 0x00};
    NSData *data = [NSData dataWithBytes:buffer length:3];
    [[self thePeripheral] writeValue:data forCharacteristic:writeToMe type:CBCharacteristicWriteWithoutResponse];
}

-(void)toggleLEDStateTo:(BOOL)state {
    static const NSUInteger LED_WRITABLE_CHARACTERISITIC_INDEX = 0;
    CBCharacteristic *writeToMe = [[self writableCharacterisitics] objectAtIndex:LED_WRITABLE_CHARACTERISITIC_INDEX];
    UInt8 buffer[3] = {0x01, 0x00, 0x00};
    if (state) {
        buffer[1] = 0x01;
    } else {
        buffer[1] = 0x00;
    }
    NSData *data = [NSData dataWithBytes:buffer length:3];
    [[self thePeripheral] writeValue:data forCharacteristic:writeToMe type:CBCharacteristicWriteWithoutResponse];
    return;
}

// When the characterisitic is updated, read it, then call resetRX: below
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    CGFloat sensorValue = [self parseAnalogReadDataIntoCGFloat:[characteristic value]];
    [[self delegate] gadgetAnalogReadDidUpdateValue:sensorValue];
    [self resetRX];
    //NSLog(@"didUpdateValueForCharacteristic: value = %f, UUID = %@", sensorValue, [characteristic UUID]);
    return;
}

// Enables analog updates to happen
-(void)startAnalogUpdates {
    const NSUInteger LED_WRITABLE_CHARACTERISITIC_INDEX = 0;
    CBCharacteristic *writeToMe = [[self writableCharacterisitics] objectAtIndex:LED_WRITABLE_CHARACTERISITIC_INDEX];
    UInt8 buffer[3] = {0xA0, 0x01, 0x00};
    NSData *data = [NSData dataWithBytes:buffer length:3];
    [[self thePeripheral] writeValue:data forCharacteristic:writeToMe type:CBCharacteristicWriteWithoutResponse];
}

// Parses the data coming from analog sensor. For now, IGNORE the possibility of the digital input reading
// This is a gross approximation, but simplifies things for now.
-(UInt16)parseAnalogReadData:(NSData *)data {
    static UInt8 buffer[128];
    [data getBytes:buffer length:128];
    UInt16 value = buffer[2] | buffer[1] << 8;
    return value;
}

// Transforms the analog reading into a value between 0.0 and 1.0 as a CGFloat, ready for some slick UI work
-(CGFloat)parseAnalogReadDataIntoCGFloat:(NSData *)data {
    static const CGFloat maxVal = 1024.0;
    UInt16 sensorValue = [self parseAnalogReadData:data];
    CGFloat result = (CGFloat)sensorValue/maxVal;
    return result;
}

// Allows the BLE module to send the next udpate
-(void)resetRX {
    UInt8 buffer[] = {0x01};
    NSData *data = [NSData dataWithBytes:buffer length:1];
    [[self thePeripheral] writeValue:data forCharacteristic:[self allCharacterisitics][3] type:CBCharacteristicWriteWithoutResponse];
}

// Handle updates to the RSSI
-(void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    [[self delegate] gadgetDidUpdateRSSI:[peripheral RSSI]];
}

@end