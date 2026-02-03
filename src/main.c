#include "usr_lib.h"

__attribute__((section(".text"))) int main() {
  char str[] = {'H', 'e', 'l', 'l', 'o', '!', '\0'};
  char *p = str;
  while (*p != 0) {
    putchar(*p);
    ++p;
  }
  while (1)
    ;
}
