// The MIT License (MIT)
// 
// Copyright (c) 2013 Alicia M. F. Key
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

// >>>>>>>>> NOTE! <<<<<<<<<
//
// Just a little code to test the board without the whole
// microcontroller running. Made for an Arduino micro, because that is
// what I had laying around to run the board test.
//
// I strongly reccomend that you not run the motor
// with the Arduino connected directly to your USB port.
// Minimally, use a hub. Better yet, use an external
// battery and don't even power it off a USB device at all.

#define ADC_IN A5
#define PWM_OUT 3
#define DIGITAL_OUT 11
const unsigned long LAG = 500;
const bool MOTOR_ENABLED = true;

void setup() {
  pinMode(DIGITAL_OUT, OUTPUT);
  Serial.begin(9600);
}

void loop() {
  if (MOTOR_ENABLED) {
    analogWrite(PWM_OUT, 0);
  }
  digitalWrite(DIGITAL_OUT, LOW);
  Serial.print("analog in: ");
  Serial.println(analogRead(ADC_IN));
  delay(LAG);
  if (MOTOR_ENABLED) {
    analogWrite(PWM_OUT, 192);
  }
  digitalWrite(DIGITAL_OUT, HIGH);
  Serial.print("analog in: ");
  Serial.println(analogRead(ADC_IN));
  delay(LAG);
}

