ENTRY( _start );

MEMORY
{
    /*
        Code starts in SRAM0, can spill into SRAM1 from higher addresses down
    */
    iram0_0_seg (RX) : org = 0x40080000, len = 0x20000 + 0x0

    /*
    */
    dram0_0_seg (RW) : org = 0x3FFB0000 + 0,
                                        len = 0x2c200 - 0

}
_heap_start = _heap_low_start;
_sram1_iram_start = 0x400A0000;
_sram1_iram_len = ( _iram_end > _sram1_iram_start) ? (_iram_end - _sram1_iram_start) : 0;
_sram1_DATA_end = 0x40000000;
_heap_end = ALIGN(_sram1_DATA_end - _sram1_iram_len - 3, 4);

/* All data should be loaded into ram, segment depends on data vs instr bus */
REGION_ALIAS("default_code_seg", iram0_0_seg);
REGION_ALIAS("default_rodata_seg", dram0_0_seg);
REGION_ALIAS("default_bss_seg", dram0_0_seg);

ASSERT(_rodata_reserved_start == ORIGIN(default_rodata_seg), "_rodata_reserved_start must start the default rodata seg");

SECTIONS
{
.iram0.vectors :
{
    _iram_start = ABSOLUTE(.);
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
    _init_start = ABSOLUTE(.);
    *(.init.literal)
    *(.init)
    _init_end = ABSOLUTE(.);
} > default_code_seg

.iram0.text :
{
    _text_start = ABSOLUTE(.);
    *(.literal .literal.* .text .text.*)
    *(.stub)
    *(.gnu.warning)
    *(.gnu.linkonce.literal.* .gnu.linkonce.t.*.literal .gnu.linkonce.t.*)
} > default_code_seg

.iram0.text_end (NOLOAD) :
{
. = ALIGN(4);
    _text_end = ABSOLUTE(.);
} > default_code_seg

/* only for explicit iram0 data */
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

/* only for explicit iram0 bss data */
.iram0.bss (NOLOAD) :
{
. = ALIGN(4);
_iram_bss_start = ABSOLUTE(.);
    *(.iram.bss .iram.bss.*)
_iram_bss_end = ABSOLUTE(.);
. = ALIGN(4);
_iram_end = ABSOLUTE(.);
} > iram0_0_seg

/* explicitly set */
.dram.appdesc : ALIGN(0x10)
{
    _rodata_reserved_start = ABSOLUTE(.);

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
    . = ALIGN(ALIGNOF(.dram.rodata));
} > default_rodata_seg
ASSERT((ADDR(.dram.rodata) == ADDR(.dram.appdesc) + SIZEOF(.dram.appdesc)), "The gap between .dram.appdesc and .dram.rodata must not exist to produce the final bin image.")

/* default rodata */
.dram.rodata : ALIGN(0x10)
{
    _rodata_start = ABSOLUTE(.);
    *(.rodata .rodata.* .sdata2 .sdata2.* .srodata .srodata.*)
    _rodata_end = ABSOLUTE(.);

    /* Literals are also RO data. */
. = ALIGN(4);
    _lit4_start = ABSOLUTE(.);
    *(*.lit4)
    *(.lit4.*)
    *(.gnu.linkonce.lit4.*)
    _lit4_end = ABSOLUTE(.);
} > default_rodata_seg
/* _dram_rodata_align = ALIGNOF(.dram.rodata);  # not sure what this is used for  */

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
    *(.dram1 .dram1.*)
    _coredump_dram_start = ABSOLUTE(.);
    *(.dram2.coredump .dram2.coredump.*)
    _coredump_dram_end = ABSOLUTE(.);
    _data_end = ABSOLUTE(.);
} > dram0_0_seg

.dram0.bss (NOLOAD) :
{
. = ALIGN(8);
_bss_start = ABSOLUTE(.);
    *(.bss .bss.*)
    *(.dynbss .dynsbss .gnu.linkonce.b .gnu.linkonce.b.* .gnu.linkonce.sb .gnu.linkonce.sb.* .gnu.linkonce.sb2 .gnu.linkonce.sb2.* .sbss .sbss.* .sbss2 .sbss2.* .scommon .share.mem)
    *(.ext_ram.bss .ext_ram.bss.*)
    *(COMMON)

. = ALIGN(8);
_bss_end = ABSOLUTE(.);
} > dram0_0_seg
ASSERT(((_bss_end - ORIGIN(dram0_0_seg)) <= LENGTH(dram0_0_seg)),
        "DRAM segment data does not fit.")

/* Marks the end of data, bss and rodata  */
.dram0.heap_start (NOLOAD) :
{
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
