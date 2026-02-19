/*
  Minimal placeholder linker script for initial bring-up.
  IMPORTANT: Replace memory regions with the official values from Infineon BSP/startup files.
*/

MEMORY
{
  FLASH (rx)  : ORIGIN = 0x10000000, LENGTH = 1024K
  RAM   (rwx) : ORIGIN = 0x08000000, LENGTH = 256K
}

ENTRY(main)

SECTIONS
{
  .text :
  {
    KEEP(*(.isr_vector))
    *(.text*)
    *(.rodata*)
  } > FLASH

  .data :
  {
    *(.data*)
  } > RAM AT > FLASH

  .bss :
  {
    *(.bss*)
    *(COMMON)
  } > RAM
}
