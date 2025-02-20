OUTPUT_FORMAT("coff-i386")
 SEARCH_DIR(/usr/ix86-coff/lib);
ENTRY(_start)
SECTIONS
{
  .text  SIZEOF_HEADERS : {
     *(.init)
    *(.text)
     *(.fini)
     etext  =  .;
  }
  .data  0x400000 + (. & 0xffc00fff) : {
    *(.data)
     edata  =  .;
  }
  .bss  SIZEOF(.data) + ADDR(.data) :
  { 					
    *(.bss)
    *(COMMON)
     end = .;
  }
  .stab  0 (NOLOAD) : 
  {
    [ .stab ]
  }
  .stabstr  0 (NOLOAD) :
  {
    [ .stabstr ]
  }
}
