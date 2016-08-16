bluetooth-low-energy
====================

This is the project I created for the [August 2013](http://www.meetup.com/Boulder-iOS/events/123912102/ "August 2013 Boulder iOS Meetup") [Boulder iOS Developer Meetup](http://www.meetup.com/Boulder-iOS "Boulder iOS Meetup") Since it is a project presented to an iOS development group, it focuses mostly on the CoreBluetooth code.

The project uses an [Arduino Uno](http://arduino.cc/ "Arduino") and the [Red Bear Lab Shield for Arduino](http://redbearlab.com "Red Bear lab homepage") The following file has the schematic diagram for the project:

### hardware-block-crop-1024.jpg ###

A block diagram of the project.

### ble-schematic-1.png ###

A simplified the schematic, abstracting the Bluetooth Low Energy shield and Arduino as a simple source of digital signal out for an LED, analog input from a photoresistor, and PWM output to drive a motor.

### ble-talk-boulder-ios-27aug2013.pdf ###

A talk presented to the [Boulder, Colorado iOS Developer meetup in August 2013.](http://www.meetup.com/Boulder-iOS/events/123912102)

### This project consists of two main directories: ###

+ `ios` The code for the iOS app, including the Red Bear Lab libraries.

+ `arduino` The code for the iOS app, also including the Red Bear Lab libraries.

## License ##

Copyright (c) 2013, Alicia Key
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

### Notes on the License ###

This project uses some Red Bear Lab code as libraries in the firmware and the software. Those files are marked with their own open-source licenses.
