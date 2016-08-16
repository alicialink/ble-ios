NOTE: This file was modified from the original Readme_SimpleControls.txt as created by Red Bear Lab to remove the servo controls.

**********

BLE Demo - Simple Controls

A.  General Description

	This demo shows how to create controls from App that read from or write to BLE Shield connected to Arduino board.

B.  System Setup

	Arduino Pins:

	Pin 4 - Digital Output pin, for example, connect to a LED
	Pin 5 - Digital Input pin, connect to a button
	Pin 6 - PWM pin, connect to a LED
	Pin A5 - Analog Input pin, connect to a variable resistor 

C.  System Design

	I. Protocol

	App to send:

	Opcode   	Data			Description
	0x01		0x0000			Digital Output Pin - Off
				0x0001			Digital Output Pin - On

	0x02		0x0000 ~ 0x00FF	PWM Value 0 ~ 255
				
	0xA0		0x0000			Analog Input Reading Disabled
				0x0001			Analog Input Reading Enabled

	App to read:

	0x0A		0x0000			Digital Input Pin - Off
				0x0001			Digital Input Pin - On

	0x0B		0x0000 ~ 0x03FF	Analog Input Value 0 ~ 1023

