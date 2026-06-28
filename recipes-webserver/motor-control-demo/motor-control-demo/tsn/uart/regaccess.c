/*
 * regaccess.c - Direct hardware register access via /dev/mem
 *
 * Allowed windows:
 *   WIN0:  0x4000 0000 - 0FFF  (TSN / scheduler / FRER)
 *   WIN1:  0x4000 7000 - 7FFF  (traffic generator)
 * Anything outside is rejected.
 *
 * Compile: gcc -shared -fPIC -O2 -o libregaccess.so regaccess.c
 */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>

#define TSN_BASE      0x40000000UL
#define TRAFFIC_BASE  0x40007000UL

#define WIN0_BASE     TSN_BASE
#define WIN0_SIZE     0x1000UL
#define WIN1_BASE     TRAFFIC_BASE
#define WIN1_SIZE     0x1000UL

static int   mem_fd   = -1;
static void *win0_map = NULL;
static void *win1_map = NULL;

const char* regaccess_device(void) { return "/dev/mem"; }

int regaccess_init(void)
{
    if (mem_fd >= 0)
        return 0;

    mem_fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (mem_fd < 0) {
        perror("regaccess: open /dev/mem");
        return -1;
    }

    win0_map = mmap(NULL, WIN0_SIZE, PROT_READ | PROT_WRITE,
                    MAP_SHARED, mem_fd, WIN0_BASE);
    if (win0_map == MAP_FAILED) {
        perror("regaccess: mmap WIN0");
        goto fail;
    }

    win1_map = mmap(NULL, WIN1_SIZE, PROT_READ | PROT_WRITE,
                    MAP_SHARED, mem_fd, WIN1_BASE);
    if (win1_map == MAP_FAILED) {
        perror("regaccess: mmap WIN1");
        goto fail;
    }

    return 0;

fail:
    if (win0_map && win0_map != MAP_FAILED) { munmap(win0_map, WIN0_SIZE); win0_map = NULL; }
    if (win1_map && win1_map != MAP_FAILED) { munmap(win1_map, WIN1_SIZE); win1_map = NULL; }
    close(mem_fd);
    mem_fd = -1;
    return -1;
}

void regaccess_close(void)
{
    if (win0_map && win0_map != MAP_FAILED) { munmap(win0_map, WIN0_SIZE); win0_map = NULL; }
    if (win1_map && win1_map != MAP_FAILED) { munmap(win1_map, WIN1_SIZE); win1_map = NULL; }
    if (mem_fd >= 0) { close(mem_fd); mem_fd = -1; }
}

static volatile uint32_t *resolve(uint64_t phys_addr)
{
    if (phys_addr & 0x3UL) {
        fprintf(stderr, "regaccess: address 0x%lX not 4-byte aligned\n",
                (unsigned long)phys_addr);
        return NULL;
    }
    if (phys_addr >= WIN0_BASE &&
        phys_addr + sizeof(uint32_t) <= WIN0_BASE + WIN0_SIZE) {
        return (volatile uint32_t *)((char *)win0_map + (phys_addr - WIN0_BASE));
    }
    if (phys_addr >= WIN1_BASE &&
        phys_addr + sizeof(uint32_t) <= WIN1_BASE + WIN1_SIZE) {
        return (volatile uint32_t *)((char *)win1_map + (phys_addr - WIN1_BASE));
    }
    fprintf(stderr,
            "regaccess: address 0x%lX out of range\n"
            "  allowed: 0x%lX-0x%lX and 0x%lX-0x%lX\n",
            (unsigned long)phys_addr,
            (unsigned long)WIN0_BASE, (unsigned long)(WIN0_BASE + WIN0_SIZE - 1),
            (unsigned long)WIN1_BASE, (unsigned long)(WIN1_BASE + WIN1_SIZE - 1));
    return NULL;
}

int regaccess_read(uint64_t phys_addr, uint32_t *out)
{
    if (mem_fd < 0 && regaccess_init() < 0)
        return -1;
    volatile uint32_t *reg = resolve(phys_addr);
    if (!reg)
        return -1;
    *out = *reg;
    return 0;
}

int regaccess_write(uint64_t phys_addr, uint32_t value, uint32_t *out)
{
    if (mem_fd < 0 && regaccess_init() < 0)
        return -1;
    volatile uint32_t *reg = resolve(phys_addr);
    if (!reg)
        return -1;
    *reg = value;
    if (out)
        *out = *reg;
    return 0;
}
