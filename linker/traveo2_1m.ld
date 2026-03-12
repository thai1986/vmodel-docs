/*
  Minimal placeholder linker script for initial bring-up.
  IMPORTANT: Replace memory regions with the official values from Infineon BSP/startup files.
*/

MEMORY
{
  /* Match CYT2B75 1M partition used by the working BSP build.
   * CM0+ occupies the beginning of flash/RAM, CM4 app starts after that.
   */
  FLASH (rx)  : ORIGIN = 0x10020000, LENGTH = 960K
  RAM   (rwx) : ORIGIN = 0x08008000, LENGTH = 96K
}

ENTRY(Reset_Handler)

SECTIONS
{
  .text :
  {
    KEEP(*(.isr_vector))
    *(.text*)
    *(.rodata*)
  } > FLASH

  _sidata = LOADADDR(.data);

  .data :
  {
    _sdata = .;
    *(.data*)
    _edata = .;
  } > RAM AT > FLASH

  .bss :
  {
    _sbss = .;
    *(.bss*)
    *(COMMON)
    _ebss = .;
  } > RAM

  _estack = ORIGIN(RAM) + LENGTH(RAM);
}
