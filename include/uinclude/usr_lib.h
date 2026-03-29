#pragma once

long syscall(long num, long arg0, long arg1, long arg2);
void putchar(char c);
long getpid(void);
void yield(void);
void printf(char *fmt, ...);
