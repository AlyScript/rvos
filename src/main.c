#include "usr_lib.h"
// #include <shell.h>

__attribute__((section(".text"))) int main() {
  // shell();
  char *str = "\nHello Kind sir\n";
  char *p = str;
  while (*p != 0) {
    putchar(*p);
    ++p;
  }
  while (1)
    ;
}
