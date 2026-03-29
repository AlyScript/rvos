#pragma once

#include <stdint.h>

struct sbiret {
    long error;
    long value;
};

void sbi_putchar(const char c);
void sbi_set_timer(uint64_t stime_value);
