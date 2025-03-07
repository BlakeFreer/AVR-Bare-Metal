#include <avr/io.h>
#include <util/delay.h>

int main(void) {

    DDRB |= 1 << PORTB5;  // Set PB5 (bulit-in LED) as output

    while(1) {
        PORTB |= 1 << PORTB5;   // set PB5 on
        _delay_ms(250);
        PORTB &= ~(1<<PORTB5);  // set PB5 off
        _delay_ms(250);
    }
}