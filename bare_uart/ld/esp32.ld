ENTRY( _start );

MEMORY
{
  /* All these values assume the flash cache is on, and have the blocks this uses subtracted from the length
  of the various regions. The 'data access port' dram/drom regions map to the same iram/irom regions but
  are connected to the data port of the CPU and eg allow bytewise access. */
  /* IRAM for PRO cpu. Not sure if happy with this, this is MMU area... */
  iram0_0_seg (RX) : org = 0x40080000, len = 0x20000 + 0x0
  /* Even though the segment name is iram, it is actually mapped to flash
  */
  iram0_2_seg (RX) : org = 0x400D0020, len = 0x330000-0x20
  /*
    (0x20 offset above is a convenience for the app binary image generation.
    Flash cache has 64KB pages. The .bin file which is flashed to the chip
    has a 0x18 byte file header, and each segment has a 0x08 byte segment
    header. Setting this offset makes it simple to meet the flash cache MMU's
    constraint that (paddr % 64KB == vaddr % 64KB).)
  */
  /* Shared data RAM, excluding memory reserved for ROM bss/data/stack.

     Enabling Bluetooth & Trace Memory features in menuconfig will decrease
     the amount of RAM available.

     Note: Length of this section *should* be 0x50000, and this extra DRAM is available
     in heap at runtime. However due to static ROM memory usage at this 176KB mark, the
     additional static memory temporarily cannot be used.
  */
  /*
    .data and .bss is read out of a portion of SRAM2
  */
  dram0_0_seg (RW) : org = 0x3FFB0000 + 0,
                                     len = 0x2c200 - 0
  /* Flash mapped constant data */
  drom0_0_seg (R) : org = 0x3F400020, len = 0x400000-0x20
  /* (See iram0_2_seg for meaning of 0x20 offset in the above.) */
  /* RTC fast memory (executable). Persists over deep sleep. */
  rtc_iram_seg(RWX) : org = 0x400C0000, len = 0x2000 - 0
  /* RTC fast memory (same block as above, rtc_iram_seg), viewed from data bus */
  rtc_data_seg(RW) : org = 0x3ff80000, len = 0x2000 - 0
  /* We reduced the size of rtc_iram_seg and rtc_data_seg by ESP_BOOTLOADER_RESERVE_RTC value.
     It reserves the amount of RTC fast memory that we use for this memory segment.
     This segment is intended for keeping bootloader rtc data (s_bootloader_retain_mem, when a Kconfig option is on).
     The aim of this is to keep data that will not be moved around and have a fixed address.
     org = 0x3ff80000 + 0x2000 - ESP_BOOTLOADER_RESERVE_RTC == SOC_RTC_DRAM_HIGH - sizeof(rtc_retain_mem_t)
  */
  rtc_fast_reserved_seg(RW) : org = 0x3ff80000 + 0x2000 - 0, len = 0
  /* RTC slow memory (data accessible). Persists over deep sleep.

     Start of RTC slow memory is reserved for ULP co-processor code + data, if enabled.
  */
  rtc_slow_seg(RW) : org = 0x50000000, len = 0x2000 - ((24))
  /* We reduced the size of rtc_slow_seg by RESERVE_RTC_MEM value.
     It reserves the amount of RTC slow memory that we use for this memory segment.
     This segment is intended for keeping rtc timer data (s_rtc_timer_retain_mem, see esp_clk.c files).
     The aim of this is to keep data that will not be moved around and have a fixed address.
     org = 0x50000000 + 0x2000 - RESERVE_RTC_MEM
  */
  rtc_slow_reserved_seg(RW) : org = 0x50000000 + 0x2000 - ((24)), len = ((24))
  /* external memory */
  extern_ram_seg(RWX) : org = 0x3F800000,
                                     len = 0x400000
}
_heap_start = _heap_low_start;
_sram1_iram_start = 0x400A0000;
_sram1_iram_len = ( _iram_end > _sram1_iram_start) ? (_iram_end - _sram1_iram_start) : 0;
/* the iram_0_0 segment is allowed to have a length of 131072 (0x20000), which exceeds the 128KB size of the physical
    sram0, meaning it CAN spill into sram1 (instr), but since sram1 instr R/W is word-reversed, instructions will appear from the high addresses first */ 

_sram1_DATA_end = 0x40000000;
_heap_end = ALIGN(_sram1_DATA_end - _sram1_iram_len - 3, 4);
/* 0x40000000 is the end of SRAM1 */
/* the heap is allowed to spill into SRAM1 (data bus) from the low addresses */
/* however, iram_0_0, mapped to SRAM0 (instr bus) can also spill into SRAM1, but from higher addresses, down*/
/* this heap end calculation, ensures that the heap stops right before the last instruction */

_data_seg_org = ORIGIN(rtc_data_seg);
/* The lines below define location alias for .rtc.data section based on Kconfig option.
   When the option is not defined then use slow memory segment
   else the data will be placed in fast memory segment */
REGION_ALIAS("rtc_data_location", rtc_slow_seg );
  REGION_ALIAS("default_code_seg", iram0_2_seg);
  REGION_ALIAS("default_rodata_seg", drom0_0_seg);
/**
 *  If rodata default segment is placed in `drom0_0_seg`, then flash's first rodata section must
 *  also be first in the segment.
 */
  ASSERT(_rodata_start == ORIGIN(default_rodata_seg),
         ".flash.appdesc section must be placed at the beginning of the rodata segment.")

SECTIONS
{
  /**
   * RTC fast memory holds RTC wake stub code,
   * including from any source file named rtc_wake_stub*.c
   */
  .rtc.text :
  {
    
 . = ALIGN(4); 
 _rtc_text_start = ABSOLUTE(.);
    *(.rtc.literal .rtc.text .rtc.text.*)
    *rtc_wake_stub*.*(.literal .text .literal.* .text.*)
    _rtc_text_end = ABSOLUTE(.);
  } > rtc_iram_seg
  /**
   * This section is required to skip rtc.text area because rtc_iram_seg and
   * rtc_data_seg are reflect the same address space on different buses.
   */
  .rtc.dummy :
  {
    _rtc_dummy_start = ABSOLUTE(.);
    _rtc_fast_start = ABSOLUTE(.);
    . = SIZEOF(.rtc.text);
    _rtc_dummy_end = ABSOLUTE(.);
  } > rtc_data_seg
  /**
   * This section located in RTC FAST Memory area.
   * It holds data marked with RTC_FAST_ATTR attribute.
   * See the file "esp_attr.h" for more information.
   */
  .rtc.force_fast :
  {
    
 . = ALIGN(4); 
 _rtc_force_fast_start = ABSOLUTE(.);
    _coredump_rtc_fast_start = ABSOLUTE(.);
    *(.rtc.fast.coredump .rtc.fast.coredump.*)
    _coredump_rtc_fast_end = ABSOLUTE(.);
    *(.rtc.force_fast .rtc.force_fast.*)
    
 . = ALIGN(4); 
 _rtc_force_fast_end = ABSOLUTE(.);
  } > rtc_data_seg
  /**
   * RTC data section holds RTC wake stub
   * data/rodata, including from any source file
   * named rtc_wake_stub*.c and the data marked with
   * RTC_DATA_ATTR, RTC_RODATA_ATTR attributes.
   * The memory location of the data is dependent on
   * CONFIG_ESP32_RTCDATA_IN_FAST_MEM option.
   */
  .rtc.data :
  {
    _rtc_data_start = ABSOLUTE(.);
    _coredump_rtc_start = ABSOLUTE(.);
    *(.rtc.coredump .rtc.coredump.*)
    _coredump_rtc_end = ABSOLUTE(.);
    *(.rtc.data .rtc.data.*)
    *(.rtc.rodata .rtc.rodata.*)
    *rtc_wake_stub*.*(.data .rodata .data.* .rodata.*)
    _rtc_data_end = ABSOLUTE(.);
  } > rtc_data_location
  /* RTC bss, from any source file named rtc_wake_stub*.c */
  .rtc.bss (NOLOAD) :
  {
    _rtc_bss_start = ABSOLUTE(.);
    *rtc_wake_stub*.*(.bss .bss.*)
    *rtc_wake_stub*.*(COMMON)
    *(.rtc.bss)
    _rtc_bss_end = ABSOLUTE(.);
  } > rtc_data_location
  /**
   * This section holds data that should not be initialized at power up
   * and will be retained during deep sleep.
   * User data marked with RTC_NOINIT_ATTR will be placed
   * into this section. See the file "esp_attr.h" for more information.
   * The memory location of the data is dependent on
   * CONFIG_ESP32_RTCDATA_IN_FAST_MEM option.
   */
  .rtc_noinit (NOLOAD):
  {
    
 . = ALIGN(4); 
 _rtc_noinit_start = ABSOLUTE(.);
    *(.rtc_noinit .rtc_noinit.*)
    
 . = ALIGN(4); 
 _rtc_noinit_end = ABSOLUTE(.);
  } > rtc_data_location
  /**
   * This section located in RTC SLOW Memory area.
   * It holds data marked with RTC_SLOW_ATTR attribute.
   * See the file "esp_attr.h" for more information.
   */
  .rtc.force_slow :
  {
    
 . = ALIGN(4); 
 _rtc_force_slow_start = ABSOLUTE(.);
    *(.rtc.force_slow .rtc.force_slow.*)
    
 . = ALIGN(4); 
 _rtc_force_slow_end = ABSOLUTE(.);
  } > rtc_slow_seg
  /**
   * This section holds RTC FAST data that should have fixed addresses.
   * The data are not initialized at power-up and are retained during deep
   * sleep.
   */
  .rtc_fast_reserved (NOLOAD):
  {
    
 . = ALIGN(4); 
 _rtc_fast_reserved_start = ABSOLUTE(.);
    /**
     * New data can only be added here to ensure existing data are not moved.
     * Because data have adhered to the end of the segment and code is relied
     * on it.
     * >> put new data here <<
     */
    KEEP(*(.bootloader_data_rtc_mem .bootloader_data_rtc_mem.*))
    _rtc_fast_reserved_end = ABSOLUTE(.);
  } > rtc_fast_reserved_seg
  _rtc_fast_reserved_length = _rtc_fast_reserved_end - _rtc_fast_reserved_start;
  ASSERT((_rtc_fast_reserved_length <= LENGTH(rtc_fast_reserved_seg)),
          "RTC FAST reserved segment data does not fit.")
  /**
   * This section holds RTC SLOW data that should have fixed addresses.
   * The data are not initialized at power-up and are retained during deep
   * sleep.
   */
  .rtc_slow_reserved (NOLOAD):
  {
    
 . = ALIGN(4); 
 _rtc_slow_reserved_start = ABSOLUTE(.);
    /**
     * New data can only be added here to ensure existing data are not moved.
     * Because data have adhered to the end of the segment and code is relied
     * on it.
     * >> put new data here <<
     */
    *(.rtc_timer_data_in_rtc_mem .rtc_timer_data_in_rtc_mem.*)
    _rtc_slow_reserved_end = ABSOLUTE(.);
  } > rtc_slow_reserved_seg
  _rtc_slow_reserved_length = _rtc_slow_reserved_end - _rtc_slow_reserved_start;
  _rtc_reserved_length = _rtc_slow_reserved_length;
  ASSERT((_rtc_slow_reserved_length <= LENGTH(rtc_slow_reserved_seg)),
          "RTC SLOW reserved segment data does not fit.")
  /* Get size of rtc slow data based on rtc_data_location alias */
  _rtc_slow_length = (ORIGIN(rtc_slow_seg) == ORIGIN(rtc_data_location))
                        ? (_rtc_force_slow_end - _rtc_data_start)
                        : (_rtc_force_slow_end - _rtc_force_slow_start);
  _rtc_fast_length = (ORIGIN(rtc_slow_seg) == ORIGIN(rtc_data_location))
                        ? (_rtc_force_fast_end - _rtc_fast_start)
                        : (_rtc_noinit_end - _rtc_fast_start);
  ASSERT((_rtc_slow_length <= LENGTH(rtc_slow_seg)),
          "RTC_SLOW segment data does not fit.")
  ASSERT((_rtc_fast_length <= LENGTH(rtc_data_seg)),
          "RTC_FAST segment data does not fit.")
  /* Send .iram0 code to iram */
  .iram0.vectors :
  {
    _iram_start = ABSOLUTE(.);
    /* Vectors go to IRAM */
    _vector_table = ABSOLUTE(.);
    . = 0x0;
    KEEP(*(.WindowVectors.text));
    . = 0x180;
    KEEP(*(.Level2InterruptVector.text));
    . = 0x1c0;
    KEEP(*(.Level3InterruptVector.text));
    . = 0x200;
    KEEP(*(.Level4InterruptVector.text));
    . = 0x240;
    KEEP(*(.Level5InterruptVector.text));
    . = 0x280;
    KEEP(*(.DebugExceptionVector.text));
    . = 0x2c0;
    KEEP(*(.NMIExceptionVector.text));
    . = 0x300;
    KEEP(*(.KernelExceptionVector.text));
    . = 0x340;
    KEEP(*(.UserExceptionVector.text));
    . = 0x3C0;
    KEEP(*(.DoubleExceptionVector.text));
    . = 0x400;
    _invalid_pc_placeholder = ABSOLUTE(.);
    *(.*Vector.literal)
    *(.UserEnter.literal);
    *(.UserEnter.text);
    . = ALIGN (16);
    *(.entry.literal)
    *(.entry.text)
    *(.init.literal)
    *(.init)
    _init_end = ABSOLUTE(.);
  } > iram0_0_seg
  .iram0.text :
  {
    /* Code marked as running out of IRAM */
    _iram_text_start = ABSOLUTE(.);
    *(.iram1 .iram1.*)

    /* all code is put in iram for now, need to fix access to iram (MMU??) */
    *(.text)
    *(.text*)
    /* */

  } > iram0_0_seg
  .dram0.data :
  {
    _data_start = ABSOLUTE(.);
    *(.gnu.linkonce.d.*)
    *(.data1)
    *(.sdata)
    *(.sdata.*)
    *(.gnu.linkonce.s.*)
    *(.gnu.linkonce.s2.*)
    *(.jcr)
    *(.data .data.*)
    /* RODATA HERE FOR NOW SINCE FLASH IS INACCESIBLE */
    /* BOOKMARK */
    /* *(.rodata .rodata.*) */
    /* */
    *(.dram1 .dram1.*)
    _coredump_dram_start = ABSOLUTE(.);
    *(.dram2.coredump .dram2.coredump.*)
    _coredump_dram_end = ABSOLUTE(.);
    _data_end = ABSOLUTE(.);
  } > dram0_0_seg
  /**
   * This section holds data that won't be initialised when startup.
   * This section locates in External RAM region.
   */
  .ext_ram_noinit (NOLOAD) :
  {
    _ext_ram_noinit_start = ABSOLUTE(.);
    *(.ext_ram_noinit*)

 . = ALIGN(4);
 _ext_ram_noinit_end = ABSOLUTE(.);
  } > extern_ram_seg
  /**
   * This section holds data that should not be initialized at power up.
   * The section located in Internal SRAM memory region. The macro _NOINIT
   * can be used as attribute to place data into this section.
   * See the "esp_attr.h" file for more information.
   */
  .noinit (NOLOAD):
  {
    
 . = ALIGN(4); 
 _noinit_start = ABSOLUTE(.);
    *(.noinit .noinit.*)
    
 . = ALIGN(4); 
 _noinit_end = ABSOLUTE(.);
  } > dram0_0_seg
  /* External Memory BSS. (Variables with EXT_RAM_BSS_ATTR attribute). */
  .ext_ram.bss (NOLOAD) :
  {
    
 . = ALIGN(4); 
 _ext_ram_bss_start = ABSOLUTE(.);
    
 . = ALIGN(4); 
 _ext_ram_bss_end = ABSOLUTE(.);
  } > extern_ram_seg
  /* Shared RAM */
  .dram0.bss (NOLOAD) :
  {
    
 . = ALIGN(8); 
 _bss_start = ABSOLUTE(.);
    /**
     * ldgen places all bss-related data to mapping[dram0_bss]
     * (See components/esp_system/app.lf).
     */
    *(.bss .bss.*)
    *(.dynbss .dynsbss .gnu.linkonce.b .gnu.linkonce.b.* .gnu.linkonce.sb .gnu.linkonce.sb.* .gnu.linkonce.sb2 .gnu.linkonce.sb2.* .sbss .sbss.* .sbss2 .sbss2.* .scommon .share.mem)
    *(.ext_ram.bss .ext_ram.bss.*)
    *(COMMON)
    
 . = ALIGN(8); 
 _bss_end = ABSOLUTE(.);
  } > dram0_0_seg
  ASSERT(((_bss_end - ORIGIN(dram0_0_seg)) <= LENGTH(dram0_0_seg)),
          "DRAM segment data does not fit.")
  .flash.appdesc : ALIGN(0x10)
  {
    /**
     * Mark flash.rodata start.
     * This can be used for mmu driver to maintain virtual address
     */
    _rodata_reserved_start = ABSOLUTE(.);
    _rodata_start = ABSOLUTE(.);
    /* !DO NOT PUT ANYTHING BEFORE THIS! */
    /* Should be the first.  App version info. */
    *(.rodata_desc .rodata_desc.*)
    /* Should be the second. Custom app version info. */
    *(.rodata_custom_desc .rodata_custom_desc.*)
    /**
     * Create an empty gap within this section. Thanks to this, the end of this
     * section will match .flah.rodata's begin address. Thus, both sections
     * will be merged when creating the final bin image.
     */
    . = ALIGN(ALIGNOF(.flash.rodata));
  } > default_rodata_seg
  ASSERT((ADDR(.flash.rodata) == ADDR(.flash.appdesc) + SIZEOF(.flash.appdesc)), "The gap between .flash.appdesc and .flash.rodata must not exist to produce the final bin image.")
  .flash.rodata : ALIGN(0x10)
  {
    _flash_rodata_start = ABSOLUTE(.);
    /* DONT PUT RODATA HERE FOR NOW */
    /* BOOKMARK */
    *(.rodata .rodata.* .sdata2 .sdata2.* .srodata .srodata.*)
    /* Addresses of memory regions reserved via SOC_RESERVE_MEMORY_REGION() */
    
 . = ALIGN(4); 
 soc_reserved_memory_region_start = ABSOLUTE(.);
    KEEP (*(.reserved_memory_address))
    soc_reserved_memory_region_end = ABSOLUTE(.);
    /* System init functions registered via ESP_SYSTEM_INIT_FN */
    
 . = ALIGN(4); 
 _esp_system_init_fn_array_start = ABSOLUTE(.);
    KEEP (*(SORT_BY_INIT_PRIORITY(.esp_system_init_fn.*)))
    _esp_system_init_fn_array_end = ABSOLUTE(.);
    _rodata_end = ABSOLUTE(.);
    /* Literals are also RO data. */
    _lit4_start = ABSOLUTE(.);
    *(*.lit4)
    *(.lit4.*)
    *(.gnu.linkonce.lit4.*)
    _lit4_end = ABSOLUTE(.);
    /* TLS data. */
    
 . = ALIGN(4); 
 _thread_local_start = ABSOLUTE(.);
    *(.tdata)
    *(.tdata.*)
    *(.tbss)
    *(.tbss.*)
    _thread_local_end = ABSOLUTE(.);
  } > default_rodata_seg
  _flash_rodata_align = ALIGNOF(.flash.rodata);
  /**
   * This section contains all the rodata that is not used
   * at runtime, helping to avoid an increase in binary size.
   */
  .flash.rodata_noload (NOLOAD) :
  {
    /**
     * This symbol marks the end of flash.rodata. It can be utilized by the MMU
     * driver to maintain the virtual address.
     * NOLOAD rodata may not be included in this section.
     */
    _rodata_reserved_end = ABSOLUTE(.);
    *(.rodata_wlog_debug .rodata_wlog_debug.*)
    *(.rodata_wlog_verbose .rodata_wlog_verbose.*)
  } > default_rodata_seg
  .flash.text :
  {
    _stext = .;
    /**
     * Mark the start of flash.text.
     * This can be used by the MMU driver to maintain the virtual address.
     */
    _instruction_reserved_start = ABSOLUTE(.);
    _text_start = ABSOLUTE(.);
    *(.literal .literal.* .text .text.*)
    *(.stub)
    *(.gnu.warning)
    *(.gnu.linkonce.literal.* .gnu.linkonce.t.*.literal .gnu.linkonce.t.*)
    *(.irom0.text) /* catch stray ICACHE_RODATA_ATTR */
    /**
     * CPU will try to prefetch up to 16 bytes of of instructions.
     * This means that any configuration (e.g. MMU, PMS) must allow
     * safe access to up to 16 bytes after the last real instruction,
     * add dummy bytes to ensure this.
     */
    . += 16;
    _text_end = ABSOLUTE(.);
    /**
     * Mark the flash.text end.
     * This can be used for MMU driver to maintain virtual address.
     */
    _instruction_reserved_end = ABSOLUTE(.);
    _etext = .;
    /**
     * Similar to _iram_start, this symbol goes here so it is
     * resolved by addr2line in preference to the first symbol in
     * the flash.text segment.
     */
    _flash_cache_start = ABSOLUTE(0);
  } > default_code_seg
  /* Marks the end of IRAM code segment */
  .iram0.text_end (NOLOAD) :
  {
    
 . = ALIGN(4); 
 _iram_text_end = ABSOLUTE(.);
  } > iram0_0_seg
  .iram0.data :
  {
    
 . = ALIGN(4); 
 _iram_data_start = ABSOLUTE(.);
    *(.iram.data .iram.data.*)
    _coredump_iram_start = ABSOLUTE(.);
    *(.iram2.coredump .iram2.coredump.*)
    _coredump_iram_end = ABSOLUTE(.);
    _iram_data_end = ABSOLUTE(.);
  } > iram0_0_seg
  .iram0.bss (NOLOAD) :
  {
    
 . = ALIGN(4); 
 _iram_bss_start = ABSOLUTE(.);
    *(.iram.bss .iram.bss.*)
    _iram_bss_end = ABSOLUTE(.);
    
 . = ALIGN(4); 
 _iram_end = ABSOLUTE(.);
  } > iram0_0_seg
  /* Marks the end of data, bss and possibly rodata  */
  .dram0.heap_start (NOLOAD) :
  {
    /* Lowest possible start address for the heap */
    
 . = ALIGN(8); 
 _heap_low_start = ABSOLUTE(.);
  } > dram0_0_seg
  /* DWARF 1 */
  .debug 0 : { *(.debug) }
  .line 0 : { *(.line) }
  /* GNU DWARF 1 extensions */
  .debug_srcinfo 0 : { *(.debug_srcinfo) }
  .debug_sfnames 0 : { *(.debug_sfnames) }
  /* DWARF 1.1 and DWARF 2 */
  .debug_aranges 0 : { *(.debug_aranges) }
  .debug_pubnames 0 : { *(.debug_pubnames) }
  /* DWARF 2 */
  .debug_info 0 : { *(.debug_info .gnu.linkonce.wi.*) }
  .debug_abbrev 0 : { *(.debug_abbrev) }
  .debug_line 0 : { *(.debug_line) }
  .debug_frame 0 : { *(.debug_frame) }
  .debug_str 0 : { *(.debug_str) }
  .debug_loc 0 : { *(.debug_loc) }
  .debug_macinfo 0 : { *(.debug_macinfo) }
  .debug_pubtypes 0 : { *(.debug_pubtypes) }
  /* DWARF 3 */
  .debug_ranges 0 : { *(.debug_ranges) }
  /* SGI/MIPS DWARF 2 extensions */
  .debug_weaknames 0 : { *(.debug_weaknames) }
  .debug_funcnames 0 : { *(.debug_funcnames) }
  .debug_typenames 0 : { *(.debug_typenames) }
  .debug_varnames 0 : { *(.debug_varnames) }
  /* GNU DWARF 2 extensions */
  .debug_gnu_pubnames 0 : { *(.debug_gnu_pubnames) }
  .debug_gnu_pubtypes 0 : { *(.debug_gnu_pubtypes) }
  /* DWARF 4 */
  .debug_types 0 : { *(.debug_types) }
  /* DWARF 5 */
  .debug_addr 0 : { *(.debug_addr) }
  .debug_line_str 0 : { *(.debug_line_str) }
  .debug_loclists 0 : { *(.debug_loclists) }
  .debug_macro 0 : { *(.debug_macro) }
  .debug_names 0 : { *(.debug_names) }
  .debug_rnglists 0 : { *(.debug_rnglists) }
  .debug_str_offsets 0 : { *(.debug_str_offsets) }
  .comment 0 : { *(.comment) }
  .note.GNU-stack 0: { *(.note.GNU-stack) }
/**
 * .xt.prop and .xt.lit sections will be used by the debugger and disassembler
 * to get more information about raw data present in the code.
 * Indeed, it may be required to add some padding at some points in the code
 * in order to align a branch/jump destination on a particular bound.
 * Padding these instructions will generate null bytes that shall be
 * interpreted as data, and not code by the debugger or disassembler.
 * This section will only be present in the ELF file, not in the final binary
 * For more details, check GCC-212
 */
  .xtensa.info 0: { *(.xtensa.info) }
  .xt.prop 0 : { *(.xt.prop .xt.prop.* .gnu.linkonce.prop.*) }
  .xt.lit 0 : { *(.xt.lit .xt.lit.* .gnu.linkonce.p.*) }
  /DISCARD/ :
  {
   *(.fini)
   *(.eh_frame_hdr)
   *(.eh_frame)
  }
}
ASSERT(((_iram_end - ORIGIN(iram0_0_seg)) <= LENGTH(iram0_0_seg)),
          "IRAM0 segment data does not fit.")
ASSERT(((_heap_low_start - ORIGIN(dram0_0_seg)) <= LENGTH(dram0_0_seg)),
          "DRAM segment data does not fit.")
