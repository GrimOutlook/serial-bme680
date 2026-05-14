# bme680-to-serial

The code and the instructions below are built for the Seeed XIAO nRF52480
Sense.

## Instructions

1. `nix develop`
2. Ensure that the device is not in it's bootloader mode.
3. `flash`
4. Double tap the button on the device.
8. The `flash` script will detect the device that appears, mount it and copy
   the built \`.uf2\` file to it.

## Notable

Instructions on getting the initial setup to flash the microcontroller came
almost entirely from [this blogpost](https://www.pavelp.cz/posts/eng-nrf52840-rust/)

