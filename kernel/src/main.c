#define ADDR 0x00040200

int main() {
  int *ptr = (int *)ADDR;
  *ptr = 0x10101010;

  while (1) {
  }
}
