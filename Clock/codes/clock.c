#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include <stdbool.h>
#include <stdlib.h>

// TYPEDEFS
typedef uint8_t byte; // changed the name


// ------------------
//LCD DRIVER ROUTINES
//
// Routines:
// LCD_Init initializes the LCD controller
// LCD_Cmd sends LCD controller command
// LCD_Char sends single ascii character to display
// LCD_Clear clears the LCD display & homes cursor
// LCD_Integer displays an integer value
// LCD_Message displays a string
// PortB is used for data communications with the HD44780-controlled LCD.
// The following defines specify which port pins connect to the controller:
#define ClearBit(x,y) x &= ~_BV(y) // equivalent to cbi(x,y)
#define SetBit(x,y) x |= _BV(y) // equivalent to sbi(x,y)
#define LCD_RS 0 // pin for LCD R/S (eg PB0)
#define LCD_E 1 // pin for LCD enable
#define DAT4 2 // pin for d4
#define DAT5 3 // pin for d5
#define DAT6 4 // pin for d6
#define DAT7 5 // pin for d7
//// The following defines are controller commands
#define CLEARDISPLAY 0x01

#define A_PIN  4
#define B_PIN  5
#define C_PIN  6
#define D_PIN  7

// 7-Segment Common Pins
#define HH_1 PC0
#define HH_2 PC1
#define MM_1 PC2
#define MM_2 PC3
#define SS_1 PC4
#define SS_2 PC5

// Button Pins
#define TOGGLE_BUTTON 2
#define SELECT_BUTTON 3



void PulseEnableLine ()
{
 SetBit(PORTB,LCD_E); // take LCD enable line high
 _delay_us(40); // wait 40 microseconds
 ClearBit(PORTB,LCD_E); // take LCD enable line low
}
void SendNibble(byte data)
{
 PORTB &= 0xC3; // 1100.0011 = clear 4 data lines
 if (data & _BV(4)) SetBit(PORTB,DAT4);
 if (data & _BV(5)) SetBit(PORTB,DAT5);
 if (data & _BV(6)) SetBit(PORTB,DAT6);
 if (data & _BV(7)) SetBit(PORTB,DAT7);
 PulseEnableLine(); // clock 4 bits into controller
}
void SendByte (byte data)
{
 SendNibble(data); // send upper 4 bits
 SendNibble(data<<4); // send lower 4 bits
 ClearBit(PORTB,5); // turn off boarduino LED
}
void LCD_Cmd (byte cmd)
{
 ClearBit(PORTB,LCD_RS); // R/S line 0 = command data
 SendByte(cmd); // send it
}
void LCD_Char (byte ch)
{
 SetBit(PORTB,LCD_RS); // R/S line 1 = character data
 SendByte(ch); // send it
}
void LCD_Init()
{
 LCD_Cmd(0x33); // initialize controller
 LCD_Cmd(0x32); // set to 4-bit input mode
 LCD_Cmd(0x28); // 2 line, 5x7 matrix
 LCD_Cmd(0x0C); // turn cursor off (0x0E to enable)
 LCD_Cmd(0x06); // cursor direction = right
 LCD_Cmd(0x01); // start with clear display
 _delay_ms(3); // wait for LCD to initialize
}
void LCD_Clear() // clear the LCD display
{
 LCD_Cmd(CLEARDISPLAY);
 _delay_ms(3); // wait for LCD to process command
}

void LCD_Message(const char *text) // display string on LCD
{
 while (*text) // do until /0 character
 LCD_Char(*text++); // send char & update char pointer
}

void LCD_Integer(int data)
// displays the integer value of DATA at current LCD cursor position
{
 char st[8] = ""; // save enough space for result
 itoa(data,st,10); // 
 LCD_Message(st); // display in on LCD
}

volatile int hours = 0, minutes = 0, seconds = 0;



// Timezone variables
int currentZone = 0;
const int timezoneOffsets[8] = {0, -5, -10, 3, 4, 9, -7, 1};
const char* timezoneNames[8] = {"IST", "UTC-5", "UTC-10", "UTC+3", "UTC+4", "UTC+9", "UTC-7", "UTC+1"};
const char* countryAbbreviations[8] = {"IND", "USA", "USA", "RUS", "UAE", "JPN", "USA", "EUR"};


// Display
void displayDigit(uint8_t commonPin, uint8_t digit) {
    PORTD = (PORTD & 0x0F) | ((digit & 0x0F) << 4);
    PORTC |= (1 << commonPin);
    _delay_us(500);
    PORTC &= ~(1 << commonPin);
}

ISR(TIMER0_COMPA_vect) {
    static uint8_t digitIndex = 0;
    uint8_t digits[6] = {hours / 10, hours % 10, minutes / 10, minutes % 10, seconds / 10, seconds % 10};
    uint8_t pins[6] = {HH_1, HH_2, MM_1, MM_2, SS_1, SS_2};

    displayDigit(pins[digitIndex], digits[digitIndex]);
    digitIndex = (digitIndex + 1) % 6;
}

void Timer0_Init() {
    TCCR0A |= (1 << WGM01);
    TCCR0B |= (1 << CS01) | (1 << CS00);
    OCR0A = 250;
    TIMSK0 |= (1 << OCIE0A);
}

// Timekeeping using Timer1
ISR(TIMER1_COMPA_vect) {
    seconds = -~seconds;
    if (seconds >= 60) { 
        seconds = 0; 
        minutes = -~minutes; 
    }
    if (minutes >= 60) { 
        minutes = 0; 
        hours = -~hours; 
    }
    if (hours >= 24) { 
        hours = 0; 
    }
}



void Timer1_Init() {
    TCCR1B |= (1 << WGM12) | (1 << CS12);
    OCR1A = 62500;
    TIMSK1 |= (1 << OCIE1A);
    sei();
}

// Button Handling
bool isButtonPressed(uint8_t pin) {
    if (!(PIND & (1 << pin))) {  // Button is active LOW
        _delay_ms(200);  // Debounce delay
        if (!(PIND & (1 << pin))) return true;  
    }
    return false;
}


// Timezone Handling
void handleTimeZones() {
    uint8_t selectedZone = 0;
    LCD_Clear();

    while (1) {
        LCD_Clear();
        LCD_Message("TZ: ");
        LCD_Message(timezoneNames[selectedZone]);
        int8_t offset = timezoneOffsets[selectedZone];
        if (offset >= 0) LCD_Message("(+");
        else LCD_Char('(');
        LCD_Integer(offset);
        LCD_Message("h)");

        LCD_Cmd(0xC0);
        LCD_Message("Country: ");
        LCD_Message(countryAbbreviations[selectedZone]);
        

        if (isButtonPressed(TOGGLE_BUTTON)) {
            selectedZone = (-~selectedZone) & 7; 
            LCD_Cmd(0xC0);  
            LCD_Message("Changed!");
            int adjHours = hours - timezoneOffsets[currentZone] + timezoneOffsets[selectedZone];

        if (adjHours < 0) adjHours += 24;  
        if (adjHours >= 24) adjHours -= 24; 
            hours = adjHours;
    	    currentZone = selectedZone;
        }
            _delay_ms(500);
        }

        if (isButtonPressed(SELECT_BUTTON)) {
     
        _delay_ms(200);
    }
}


void enterISTTime() {
    LCD_Clear();
    LCD_Message("Enter Time:");
    _delay_ms(1000);

    for (uint8_t i = 0; i < 6; i++) {
        uint8_t value = 0;
        while (1) {
            LCD_Cmd(0xC0);
            LCD_Message((i < 2) ? "HH: " : (i < 4) ? "MM: " : "SS: ");
            LCD_Integer(value);

            if (isButtonPressed(TOGGLE_BUTTON)) {
                value = (value + 1) % 10;
            }

            if (isButtonPressed(SELECT_BUTTON)) {
                break;
            }
        }

        switch (i) {
            case 0: hours += value * 10; break;
            case 1: hours += value; break;
            case 2: minutes += value * 10; break;
            case 3: minutes += value; break;
            case 4: seconds += value * 10; break;
            case 5: seconds += value; break;
        }
    }
}

int main() {
    DDRB = 0xFF;  // Port B output for LCD
    DDRD = 0xF0;  // Upper bits for 7-segment, lower for input
    PORTD |= (1 << TOGGLE_BUTTON) | (1 << SELECT_BUTTON);  // Enable internal pull-ups
    DDRC = 0xFF;  // Port C output for 7-segment selection

    LCD_Init();
    enterISTTime();  // User enters time

    Timer0_Init();  // 7-segment display multiplexing
    Timer1_Init();  // Timekeeping

    while (1) {
        // If SELECT_BUTTON is pressed, enter timezone selection mode
        if (isButtonPressed(SELECT_BUTTON)) {
            handleTimeZones();
        }
    }
}

