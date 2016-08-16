/*

Copyright (c) 2012 RedBearLab

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

/* 08 August 2013
 *
 * Modified by Alicia M. F. Key
 *
 * This is made to work with the Red Bear Labs Bluetooth Low Energy shield. The original can be found as "SimpleControls_Sketch" on their GitHub repo at https://github.com/RedBearLab
 *
 * I made modifications to remove the servo motor (since I am not using it for the demo) and add a watchdog timer for the motor to make sure it doesn't run forever.
 */

#include <SPI.h>
#include <ble.h>
 
#define DIGITAL_OUT_PIN    4
#define DIGITAL_IN_PIN     5
#define PWM_PIN            6
#define ANALOG_IN_PIN      A5

const unsigned long MOTOR_WATCHDOG_TIMEOUT_MS = 60000;
unsigned long watchdogOk = 0;
byte currentMotorSpeed = 0;

void setup()
{
  Serial.begin(9600);

  SPI.setDataMode(SPI_MODE0);
  SPI.setBitOrder(LSBFIRST);
  SPI.setClockDivider(SPI_CLOCK_DIV16);
  SPI.begin();

  ble_begin();
  
  pinMode(DIGITAL_OUT_PIN, OUTPUT);
  pinMode(DIGITAL_IN_PIN, INPUT);
  
  watchdogOk = millis();

  Serial.println("system is running");
}

void loop()
{
  static boolean analog_enabled = false;
  static byte old_state = LOW;
  
  // If data is ready
  while(ble_available())
  {
    // read out command and data
    byte data0 = ble_read();
    byte data1 = ble_read();
    byte data2 = ble_read();
    
    if (data0 == 0x01)  // Command is to control digital out pin
    {
      if (data1 == 0x01)
        digitalWrite(DIGITAL_OUT_PIN, HIGH);
      else
        digitalWrite(DIGITAL_OUT_PIN, LOW);
    }
    else if (data0 == 0xA0) // Command is to enable analog in reading
    {
      if (data1 == 0x01) {
        analog_enabled = true;
        Serial.println("analog read enabled");
      } else {
        analog_enabled = false;
        Serial.println("analog read DISABLED");
      }
    }
    else if (data0 == 0x02) // Command is to control PWM pin
    {
      analogWrite(PWM_PIN, data1);
      currentMotorSpeed = data1;
    }
  }
  
  if (analog_enabled)  // if analog reading enabled
  {
    // Read and send out
    uint16_t value = analogRead(ANALOG_IN_PIN); 
    ble_write(0x0B);
    ble_write(value >> 8);
    ble_write(value);
    // Serial.print("Sent: ");
    // Serial.println(value);
  }
  
  // If digital in changes, report the state
  if (digitalRead(DIGITAL_IN_PIN) != old_state)
  {
    old_state = digitalRead(DIGITAL_IN_PIN);
    
    if (digitalRead(DIGITAL_IN_PIN) == HIGH)
    {
      ble_write(0x0A);
      ble_write(0x01);
      ble_write(0x00);    
    }
    else
    {
      ble_write(0x0A);
      ble_write(0x00);
      ble_write(0x00);
    }
  }
  
  if (!ble_connected())
  {
    analog_enabled = false;
    digitalWrite(DIGITAL_OUT_PIN, LOW);
  }
 
  // Deal with the watchdog timer
  doWatchdog();

  // Allow BLE Shield to send/receive data
  ble_do_events();  
}

// Watchdog timer for the motor. This is so the motor doesn't
// run and run and run if its speed isn't updates
//
// If the motor's speed is 0 (stopped) then don't do anything
//
// If the motor's speed is non zero, then make sure it hasn't
// been running that way longer than the timeout.

void doWatchdog() {
  if (currentMotorSpeed == 0) {
    watchdogOk = millis(); 
  } else if (millis() - watchdogOk > MOTOR_WATCHDOG_TIMEOUT_MS) {
    analogWrite(PWM_PIN, 0);
    currentMotorSpeed = 0;    
  }
}
