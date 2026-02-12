#include "usr_lib.h"

__attribute__((section(".text"))) int main() {
  char *str = "\nHello Kind sir\n";
  char *p = str;
  while (*p != 0) {
    putchar(*p);
    ++p;
  }
  while (1)
    ;
}
