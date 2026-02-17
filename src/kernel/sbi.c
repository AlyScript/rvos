__attribute__((section(".text.sys")))
void sbi_putchar(const char c) {
  register int a0 asm("a0") = (int)(c);
  register int a6 asm("a6") = 0;
  register int a7 asm("a7") = 1;

  asm volatile("ecall" : "+r"(a0) : "r"(a6), "r"(a7) : "memory");
}
