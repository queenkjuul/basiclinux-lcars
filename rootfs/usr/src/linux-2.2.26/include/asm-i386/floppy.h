/*
 * Architecture specific parts of the Floppy driver
 *
 * This file is subject to the terms and conditions of the GNU General Public
 * License.  See the file "COPYING" in the main directory of this archive
 * for more details.
 *
 * Copyright (C) 1995
 */
#ifndef __ASM_I386_FLOPPY_H
#define __ASM_I386_FLOPPY_H

#include <linux/vmalloc.h>


/*
 * The DMA channel used by the floppy controller cannot access data at
 * addresses >= 16MB
 *
 * Went back to the 1MB limit, as some people had problems with the floppy
 * driver otherwise. It doesn't matter much for performance anyway, as most
 * floppy accesses go through the track buffer.
 */
#define _CROSS_64KB(a,s,vdma) \
(!vdma && ((unsigned long)(a)/K_64 != ((unsigned long)(a) + (s) - 1) / K_64))

#define CROSS_64KB(a,s) _CROSS_64KB(a,s,use_virtual_dma & 1)


#define SW fd_routine[use_virtual_dma&1]
#define CSW fd_routine[can_use_virtual_dma & 1]


#define fd_inb(port)			inb_p(port)
#define fd_outb(port,value)		outb_p(port,value)

#define fd_request_dma()        CSW._request_dma(FLOPPY_DMA,"floppy")
#define fd_free_dma()           CSW._free_dma(FLOPPY_DMA)
#define fd_enable_irq()         enable_irq(FLOPPY_IRQ)
#define fd_disable_irq()        disable_irq(FLOPPY_IRQ)
#define fd_free_irq()		free_irq(FLOPPY_IRQ, NULL)
#define fd_get_dma_residue()    SW._get_dma_residue(FLOPPY_DMA)
#define fd_dma_mem_alloc(size)	SW._dma_mem_alloc(size)
#define fd_dma_setup(addr, size, mode, io) SW._dma_setup(addr, size, mode, io)

#define FLOPPY_CAN_FALLBACK_ON_NODMA

static int virtual_dma_count=0;
static int virtual_dma_residue=0;
static char *virtual_dma_addr=0;
static int virtual_dma_mode=0;
static int doing_pdma=0;

static void floppy_hardint(int irq, void *dev_id, struct pt_regs * regs)
{
	register unsigned char st;

#undef TRACE_FLPY_INT
#define NO_FLOPPY_ASSEMBLER

#ifdef TRACE_FLPY_INT
	static int calls=0;
	static int bytes=0;
	static int dma_wait=0;
#endif
	if(!doing_pdma) {
		floppy_interrupt(irq, dev_id, regs);
		return;
	}

#ifdef TRACE_FLPY_INT
	if(!calls)
		bytes = virtual_dma_count;
#endif

#ifndef NO_FLOPPY_ASSEMBLER
	__asm__ (
       "testl %1,%1
	je 3f
1:	inb %w4,%b0
	andb $160,%b0
	cmpb $160,%b0
	jne 2f
	incw %w4
	testl %3,%3
	jne 4f
	inb %w4,%b0
	movb %0,(%2)
	jmp 5f
4:     	movb (%2),%0
	outb %b0,%w4
5:	decw %w4
	outb %0,$0x80
	decl %1
	incl %2
	testl %1,%1
	jne 1b
3:	inb %w4,%b0
2:	"
       : "=a" ((char) st), 
       "=c" ((long) virtual_dma_count), 
       "=S" ((long) virtual_dma_addr)
       : "b" ((long) virtual_dma_mode),
       "d" ((short) virtual_dma_port+4), 
       "1" ((long) virtual_dma_count),
       "2" ((long) virtual_dma_addr));
#else	
	{
		register int lcount;
		register char *lptr;

		st = 1;
		for(lcount=virtual_dma_count, lptr=virtual_dma_addr; 
		    lcount; lcount--, lptr++) {
			st=inb(virtual_dma_port+4) & 0xa0 ;
			if(st != 0xa0) 
				break;
			if(virtual_dma_mode)
				outb_p(*lptr, virtual_dma_port+5);
			else
				*lptr = inb_p(virtual_dma_port+5);
		}
		virtual_dma_count = lcount;
		virtual_dma_addr = lptr;
		st = inb(virtual_dma_port+4);
	}
#endif

#ifdef TRACE_FLPY_INT
	calls++;
#endif
	if(st == 0x20)
		return;
	if(!(st & 0x20)) {
		virtual_dma_residue += virtual_dma_count;
		virtual_dma_count=0;
#ifdef TRACE_FLPY_INT
		printk("count=%x, residue=%x calls=%d bytes=%d dma_wait=%d\n", 
		       virtual_dma_count, virtual_dma_residue, calls, bytes,
		       dma_wait);
		calls = 0;
		dma_wait=0;
#endif
		doing_pdma = 0;
		floppy_interrupt(irq, dev_id, regs);
		return;
	}
#ifdef TRACE_FLPY_INT
	if(!virtual_dma_count)
		dma_wait++;
#endif
}

static void fd_disable_dma(void)
{
	if(! (can_use_virtual_dma & 1))
		disable_dma(FLOPPY_DMA);
	doing_pdma = 0;
	virtual_dma_residue += virtual_dma_count;
	virtual_dma_count=0;
}

static int vdma_request_dma(unsigned int dmanr, const char * device_id)
{
	return 0;
}

static void vdma_nop(unsigned int dummy)
{
}


static int vdma_get_dma_residue(unsigned int dummy)
{
	return virtual_dma_count + virtual_dma_residue;
}


static int fd_request_irq(void)
{
	if(can_use_virtual_dma)
		return request_irq(FLOPPY_IRQ, floppy_hardint,SA_INTERRUPT,
						   "floppy", NULL);
	else
		return request_irq(FLOPPY_IRQ, floppy_interrupt,
						   SA_INTERRUPT|SA_SAMPLE_RANDOM,
						   "floppy", NULL);	

}

static unsigned long dma_mem_alloc(unsigned long size)
{
	return __get_dma_pages(GFP_KERNEL,__get_order(size));
}


static unsigned long vdma_mem_alloc(unsigned long size)
{
	return (unsigned long) vmalloc(size);

}

#define nodma_mem_alloc(size) vdma_mem_alloc(size)

static void _fd_dma_mem_free(unsigned long addr, unsigned long size)
{
	if((unsigned int) addr >= (unsigned int) high_memory)
		return vfree((void *)addr);
	else
		free_pages(addr, __get_order(size));		
}

#define fd_dma_mem_free(addr, size)  _fd_dma_mem_free(addr, size) 

static void _fd_chose_dma_mode(char *addr, unsigned long size)
{
	if(can_use_virtual_dma == 2) {
		if((unsigned int) addr >= (unsigned int) high_memory ||
		   virt_to_bus(addr) >= 0x1000000 ||
		   _CROSS_64KB(addr, size, 0))
			use_virtual_dma = 1;
		else
			use_virtual_dma = 0;
	} else {
		use_virtual_dma = can_use_virtual_dma & 1;
	}
}

#define fd_chose_dma_mode(addr, size) _fd_chose_dma_mode(addr, size)


static int vdma_dma_setup(char *addr, unsigned long size, int mode, int io)
{
	doing_pdma = 1;
	virtual_dma_port = io;
	virtual_dma_mode = (mode  == DMA_MODE_WRITE);
	virtual_dma_addr = addr;
	virtual_dma_count = size;
	virtual_dma_residue = 0;
	return 0;
}

static int hard_dma_setup(char *addr, unsigned long size, int mode, int io)
{
#ifdef FLOPPY_SANITY_CHECK
	if (CROSS_64KB(addr, size)) {
		printk("DMA crossing 64-K boundary %p-%p\n", addr, addr+size);
		return -1;
	}
#endif
	/* actual, physical DMA */
	doing_pdma = 0;
	clear_dma_ff(FLOPPY_DMA);
	set_dma_mode(FLOPPY_DMA,mode);
	set_dma_addr(FLOPPY_DMA,virt_to_bus(addr));
	set_dma_count(FLOPPY_DMA,size);
	enable_dma(FLOPPY_DMA);
	return 0;
}

struct fd_routine_l {
	int (*_request_dma)(unsigned int dmanr, const char * device_id);
	void (*_free_dma)(unsigned int dmanr);
	int (*_get_dma_residue)(unsigned int dummy);
	unsigned long (*_dma_mem_alloc) (unsigned long size);
	int (*_dma_setup)(char *addr, unsigned long size, int mode, int io);
} fd_routine[] = {
	{
		request_dma,
		free_dma,
		get_dma_residue,
		dma_mem_alloc,
		hard_dma_setup
	},
	{
		vdma_request_dma,
		vdma_nop,
		vdma_get_dma_residue,
		vdma_mem_alloc,
		vdma_dma_setup
	}
};


static int FDC1 = 0x3f0;
static int FDC2 = -1;

#define FLOPPY0_TYPE	({				\
	unsigned long flags;				\
	unsigned char val;				\
	spin_lock_irqsave(&rtc_lock, flags);		\
	val = (CMOS_READ(0x10) >> 4) & 15;		\
	spin_unlock_irqrestore(&rtc_lock, flags);	\
	val;						\
})

#define FLOPPY1_TYPE	({				\
	unsigned long flags;				\
	unsigned char val;				\
	spin_lock_irqsave(&rtc_lock, flags);		\
	val = CMOS_READ(0x10) & 15;			\
	spin_unlock_irqrestore(&rtc_lock, flags);	\
	val;						\
})

#define N_FDC 2
#define N_DRIVE 8

#define FLOPPY_MOTOR_MASK 0xf0

#define AUTO_DMA


#endif /* __ASM_I386_FLOPPY_H */
