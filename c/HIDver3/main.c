/**
 * Project: AVR ATtiny USB Tutorial at http://codeandlife.com/
 * Author: Joonas Pihlajamaa, joonas.pihlajamaa@iki.fi
 * Base on V-USB example code by Christian Starkjohann
 * Copyright: (c) 2008 by OBJECTIVE DEVELOPMENT Software GmbH
 * License: GNU GPL v3 (see License.txt)
 */
#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/wdt.h>
#include <avr/eeprom.h>
#include <util/delay.h>
#include <inttypes.h>
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include "usbdrv.h"
//#include "conversion.h"
#define F_CPU 12000000
// *********************************
// *** BASIC PROGRAM DEFINITIONS ***
// *********************************

#define MSG_BUFFER_SIZE 32 

// ************************
// *** USB HID ROUTINES ***
// ************************

// From Frank Zhao's USB Business Card project
// http://www.frank-zhao.com/cache/usbbusinesscard_details.php
PROGMEM char usbHidReportDescriptor[USB_CFG_HID_REPORT_DESCRIPTOR_LENGTH] = {
    0x05, 0x01,                    // USAGE_PAGE (Generic Desktop)
    0x09, 0x06,                    // USAGE (Keyboard)
    0xa1, 0x01,                    // COLLECTION (Application)
    0x75, 0x01,                    //   REPORT_SIZE (1)
    0x95, 0x08,                    //   REPORT_COUNT (8)
    0x05, 0x07,                    //   USAGE_PAGE (Keyboard)(Key Codes)
    0x19, 0xe0,                    //   USAGE_MINIMUM (Keyboard LeftControl)(224)
    0x29, 0xe7,                    //   USAGE_MAXIMUM (Keyboard Right GUI)(231)
    0x15, 0x00,                    //   LOGICAL_MINIMUM (0)
    0x25, 0x01,                    //   LOGICAL_MAXIMUM (1)
    0x81, 0x02,                    //   INPUT (Data,Var,Abs) ; Modifier byte
    0x95, 0x01,                    //   REPORT_COUNT (1)
    0x75, 0x08,                    //   REPORT_SIZE (8)
    0x81, 0x03,                    //   INPUT (Cnst,Var,Abs) ; Reserved byte
    0x95, 0x05,                    //   REPORT_COUNT (5)
    0x75, 0x01,                    //   REPORT_SIZE (1)
    0x05, 0x08,                    //   USAGE_PAGE (LEDs)
    0x19, 0x01,                    //   USAGE_MINIMUM (Num Lock)
    0x29, 0x05,                    //   USAGE_MAXIMUM (Kana)
    0x91, 0x02,                    //   OUTPUT (Data,Var,Abs) ; LED report
    0x95, 0x01,                    //   REPORT_COUNT (1)
    0x75, 0x03,                    //   REPORT_SIZE (3)
    0x91, 0x03,                    //   OUTPUT (Cnst,Var,Abs) ; LED report padding
    0x95, 0x06,                    //   REPORT_COUNT (6)
    0x75, 0x08,                    //   REPORT_SIZE (8)
    0x15, 0x00,                    //   LOGICAL_MINIMUM (0)
    0x25, 0x65,                    //   LOGICAL_MAXIMUM (101)
    0x05, 0x07,                    //   USAGE_PAGE (Keyboard)(Key Codes)
    0x19, 0x00,                    //   USAGE_MINIMUM (Reserved (no event indicated))(0)
    0x29, 0x65,                    //   USAGE_MAXIMUM (Keyboard Application)(101)
    0x81, 0x00,                    //   INPUT (Data,Ary,Abs)
    0xc0                           // END_COLLECTION
};

typedef struct {
	uint8_t modifier;
	uint8_t reserved;
	uint8_t keycode[6];
} keyboard_report_t;

static keyboard_report_t keyboard_report; // sent to PC
volatile static uchar LED_state = 0; // received from PC
static uchar idleRate; // repeat rate for keyboards

#define STATE_SEND 1
#define STATE_DONE 0
volatile uint8_t value, buffer[8];
volatile int bit = 0, h,j;
volatile uint8_t res = 0, message;
static uchar messageState = STATE_DONE;
static uchar messageBuffer[1] = "";
static uchar messagePtr = 0;
static uchar bufferPtr = 0;
static uchar messageCharNext = 1;
//static uchar messageChecker[32] = "";
static uchar messageR = 0;
#define MOD_SHIFT_LEFT (1<<1)

// The buildReport is called by main loop and it starts transmitting
// characters when messageState == STATE_SEND. The message is stored
// in messageBuffer and messagePtr tells the next character to send.
// Remember to reset messagePtr to 0 after populating the buffer!
/*
uchar ch_checker()
{
	int i;

	for(i=0;i<MSG_BUFFER_SIZE-2;i++)
	{
		if(messageBuffer[i] == '$')
		{
			if(messageBuffer[i+2] =='&')
			{
				messagePtr=0;
				messageR = 1;
				return messageBuffer[i+1];
			}

			else
				return 0;
		}
		else
			return 0;
	}

return 0;
}
*/
void conversion()
{
	if (res == 0x1c)
	{
		message = 'a';
	}
	if (res == 0x32)
	{
		message = 'b';
	}
	if (res == 0x21)
	{
		message = 'c';
	}
	if (res == 0x23)
	{
		message = 'd';
	}
	if (res == 0x24)
	{
		message = 'e';
	}
	if (res == 0x2b)
	{
		message = 'f';
	}
	if (res == 0x34)
	{
		message = 'g';
	}
	if (res == 0x33)
	{
		message = 'h';
	}
	if (res == 0x43)
	{
		message = 'i';
	}
	if (res == 0x3b)
	{
		message = 'j';
	}
	if (res == 0x42)
	{
		message = 'k';
	}
	if (res == 0x4b)
	{
		message = 'l';
	}
	if (res == 0x3a)
	{
		message = 'm';
	}
	if (res == 0x31)
	{
		message = 'n';
	}
	if (res == 0x44)
	{
		message = 'o';
	}
	if (res == 0x4d)
	{
		message = 'p';
	}
	if (res == 0x15)
	{
		message = 'q';
	}
	if (res == 0x2d)
	{
		message = 'r';
	}
	if (res == 0x1b)
	{
		message = 's';
	}
	if (res == 0x2c)
	{
		message = 't';
	}
	if (res == 0x3c)
	{
		message = 'u';
	}
	if (res == 0x2a)
	{
		message = 'v';
	}
	if (res == 0x1d)
	{
		message = 'w';
	}
	if (res == 0x22)
	{
		message = 'x';
	}
	if (res == 0x35)
	{
		message = 'y';
	}
	if (res == 0x1a)
	{
		message = 'z';
	}

}

uchar buildReport() {
    uchar ch;
    
    if(messageState == STATE_DONE || message == 0)
    {
        keyboard_report.modifier = 0;
        keyboard_report.keycode[0] = 0;
        return STATE_DONE;
    }

    if(messageCharNext)
    { // send a keypress
    //    ch = ch_checker();
    //    ch = messageBuffer[1];
    	ch = message;
        // convert character to modifier + keycode
        	if(ch >= '0' && ch <= '9')
        	{
            keyboard_report.modifier = 0;
            keyboard_report.keycode[0] = (ch == '0') ? 39 : 30+(ch-'1');
        	}

        	else if(ch >= 'a' && ch <= 'z')
        	{
            keyboard_report.modifier = (LED_state & 2) ? MOD_SHIFT_LEFT : 0;
            keyboard_report.keycode[0] = 4+(ch-'a');
        	}

        	else if(ch >= 'A' && ch <= 'Z')
        	{
            keyboard_report.modifier = (LED_state & 2) ? 0 : MOD_SHIFT_LEFT;
            keyboard_report.keycode[0] = 4+(ch-'A');
        	}
        	else
        	{
            keyboard_report.modifier = 0;
            keyboard_report.keycode[0] = 0;
            	switch(ch)
            	{
            		case '.':
            			keyboard_report.keycode[0] = 0x37;
            			break;
            		case '_':
            			keyboard_report.modifier = MOD_SHIFT_LEFT;
            		case '-':
            			keyboard_report.keycode[0] = 0x2D;
            			break;
            		case ' ':
            			keyboard_report.keycode[0] = 0x2C;
            			break;
            		case '\t':
            			keyboard_report.keycode[0] = 0x2B;
            			break;
            		case '\n':
            			keyboard_report.keycode[0] = 0x28;
            			break;
            	}
        	}
    }
    	else
    	{ // key release before the next keypress!
        keyboard_report.modifier = 0;
        keyboard_report.keycode[0] = 0;
    	}
    
    messageCharNext = !messageCharNext; // invert
    
    return STATE_SEND;
}

usbMsgLen_t usbFunctionSetup(uchar data[8]) {
    usbRequest_t *rq = (void *)data;

    if((rq->bmRequestType & USBRQ_TYPE_MASK) == USBRQ_TYPE_CLASS) {
        switch(rq->bRequest) {
        case USBRQ_HID_GET_REPORT: // send "no keys pressed" if asked here
            // wValue: ReportType (highbyte), ReportID (lowbyte)
            usbMsgPtr = (void *)&keyboard_report; // we only have this one
            keyboard_report.modifier = 0;
            keyboard_report.keycode[0] = 0;
            return sizeof(keyboard_report);
		case USBRQ_HID_SET_REPORT: // if wLength == 1, should be LED state
            return (rq->wLength.word == 1) ? USB_NO_MSG : 0;
        case USBRQ_HID_GET_IDLE: // send idle rate to PC as required by spec
            usbMsgPtr = &idleRate;
            return 1;
        case USBRQ_HID_SET_IDLE: // save idle rate as required by spec
            idleRate = rq->wValue.bytes[1];
            return 0;
        }
    }
    
    return 0; // by default don't return any data
}


#define abs(x) ((x) > 0 ? (x) : (-x))

// Called by V-USB after device reset
void hadUsbReset() {
    int frameLength, targetLength = (unsigned)(1499 * (double)F_CPU / 10.5e6 + 0.5);
    int bestDeviation = 9999;
    uchar trialCal, bestCal = 0, step, region;

    // do a binary search in regions 0-127 and 128-255 to get optimum OSCCAL
    for(region = 0; region <= 1; region++) {
        frameLength = 0;
        trialCal = (region == 0) ? 0 : 128;
        
        for(step = 64; step > 0; step >>= 1) { 
            if(frameLength < targetLength) // true for initial iteration
                trialCal += step; // frequency too low
            else
                trialCal -= step; // frequency too high
                
            OSCCAL = trialCal;
            frameLength = usbMeasureFrameLength();
            
            if(abs(frameLength-targetLength) < bestDeviation) {
                bestCal = trialCal; // new optimum found
                bestDeviation = abs(frameLength -targetLength);
            }
        }
    }

    OSCCAL = bestCal;
}


ISR(INT1_vect)
{
	value = PINA & _BV(PA0);
	buffer[bufferPtr++] = value ;
	bit++;

	if(bit == 8)
	{
		//memcpy(messageBuffer, (char*)&buffer, 1);
		for (j = 0 ; j != 8 ; j++)
			{
			    res <<= 1;					//converting byte to integer
			    res |= buffer[j];
			}
		conversion();

		for(h=0;h<8;h++)
		    	{
		    		buffer[h] = '0';
		    	}
		bufferPtr = 0;
	}

}

int main() {
	uchar i;
	DDRA &= ~_BV(0);
    messagePtr = 0;
    messageState = STATE_SEND;
	
    for(i=0; i<sizeof(keyboard_report); i++) // clear report initially
        ((uchar *)&keyboard_report)[i] = 0;
    
    wdt_enable(WDTO_1S); // enable 1s watchdog timer

    usbInit();
    usbDeviceDisconnect(); // enforce re-enumeration
    for(i = 0; i<250; i++) { // wait 500 ms
        wdt_reset(); // keep the watchdog happy
        _delay_ms(2);
    }
    usbDeviceConnect();
    for(i=0;i<MSG_BUFFER_SIZE;i++)
    	{
    		messageBuffer[i] = '0';
    	}

    EICRA |= _BV(ISC10) | _BV(ISC11);
    EIMSK |= _BV(INT1);
    sei(); // Enable interrupts after re-enumeration
	
    while(1)
    {
        wdt_reset(); // keep the watchdog happy
        usbPoll();

        // characters are sent when messageState == STATE_SEND and after receiving
        // the initial LED state from PC (good way to wait until device is recognized)
       // ch_checker();
        if(messageR)
        {
        	messageR=0;
        	if(usbInterruptIsReady() && messageState == STATE_SEND)
        		{
        		messageState = buildReport();
        		message = 0;
        		usbSetInterrupt((void *)&keyboard_report, sizeof(keyboard_report));
        		}
        }
    }
	
    return 0;
}
