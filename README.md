# Bare Metal AVR

_This tutorial focuses on the environment setup. For an explanation of bare metal programming on AVR, see [LowLevelLearning](https://www.youtube.com/@LowLevelTV)'s video <https://www.youtube.com/watch?v=j4xw8QomkXs> which inspired this tutorial._

"Bare metal" programming, that is programming at the hardware register level, is an excellent way to learn microcontrollers. This tutorial will help you set up your development environment and build your first bare metal project.

This tutorial assumes you are running Linux. If you are on Windows, run all the commands in WSL and see the
[Flashing from WSL](#flashing-from-wsl) section when you are ready to flash.

- [Install the AVR Toolchain](#install-the-avr-toolchain)
- [Write your first program](#write-your-first-program)
- [Configure VS Code](#configure-vs-code)
- [Compile and Flash](#compile-and-flash)
  - [Flashing from WSL](#flashing-from-wsl)
- [Project Ideas](#project-ideas)

## Install the AVR Toolchain

```bash
sudo apt install avr-libc avrdude binutils-avr gcc-avr
```

## Write your first program

_See this video for an explanation of the code <https://www.youtube.com/watch?v=j4xw8QomkXs>._

Save this file as `blink.c` adjacent to the `Makefile`.

```c
#include <avr/io.h>
#include <util/delay.h>

int main(void) {

    DDRB |= 1 << PORTB5;  // Set PB5 (built-in LED) as output

    while(1) {
        PORTB |= 1 << PORTB5;   // set PB5 on
        _delay_ms(250);
        PORTB &= ~(1<<PORTB5);  // set PB5 off
        _delay_ms(250);
    }
}
```

## Configure VS Code

Install the [C/C++ Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools).

1. From the Command Palette (CTRL + SHIFT + P), run `C/C++: Edit Configurations (UI)`.
2. Set the "Compiler Path" to your avr-gcc path (run `which avr-gcc` to find yours).
3. Add `__AVR_ATmega328P__` to the list of "Defines."

## Compile and Flash

Connect your Arduino Uno to your computer. Determine the device port by running

```bash
$ ls /dev | grep ACM
ttyACM0
```

If necessary, update the `PORT` Makefile variable from `-P /dev/ttyACM0` to `-P /dev/<PORT>`. If that command returns multiple devices, you may have to try multiple to figure out which is the Arduino.

Run `make blink.hex` to compile your code. The Makefile assumes that `<FILE>.hex` comes from `<FILE>.c`.

Run `make burn blink.hex` to flash it to the Arduino. The program will begin running immediately and you should see the onboard LED flashing twice per second.

### Flashing from WSL

We must "attach" the USB-connected Arduino to WSL before flashing.

Install `usbipd` from <https://github.com/dorssel/usbipd-win>.

From a __Windows__ Command Prompt, run `usbipb list` and note the `BUSID` of the Arduino, in this case `6-4`.

```bash
C:\>usbipd list
Connected:
BUSID  VID:PID    DEVICE                        STATE
...
6-4    2341:0043  Arduino Uno (COM15)           Attached
...
```

Bind the Arduino to enable sharing then attach it to WSL.

```bash
C:\>usbipd bind --busid 6-4
C:\>usbipd attach --busid 6-4 --wsl
```

The Arduino is now connected to WSL and cannot be accessed by Windows. You can run `make burn <FILE>.hex` to flash code to the Arduino.

To bring the Arduino back to Windows, run (in Windows Command Prompt)

```bash
usbipd detach --busid 6-4
```

## Project Ideas

Roughly in order of increasing difficulty.

You will need to continuously reference the ATmega328P datasheet when programming bare metal.

<https://ww1.microchip.com/downloads/en/DeviceDoc/Atmel-7810-Automotive-Microcontrollers-ATmega328P_Datasheet.pdf>

To use a peripheral, find its section in the datasheet, read the overview, then determine which registers need to be modified. Notice that each register has a default value, so if you like the default then you don't need to explicitly set it in code.

1. Blink an LED every 1 second.
   1. Start with the `_delay_ms()` function from `util/delay.h`, then write your own delay function using a hardware timer. Verify the exact timing with an oscilloscope. You should be able to get exactly 1000 ms delay, not 999 or 1001.
2. Turn on an LED with a button.
3. Control an LED with a button using interrupts.
4. Sweep the brightness of an LED using PWM.
5. Control an LED's brightness using a potentiometer as an analog input.
6. Send Serial messages to your computer. The Arduino IDE has a Serial Monitor window and there's probably a VS Code extension for one.
   1. There are Linux CLI tools for viewing Serial messages, see <https://arduino.stackexchange.com/questions/79058/access-serial-monitor-on-linux-cli-using-arduino-cli>.
