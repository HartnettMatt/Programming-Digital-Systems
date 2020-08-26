#include <stdio.h>

int min(int a, int b){
  return (a < b)?a:b;
}

int main() {
  printf("Hello\n");
  int x = 5;
  int y = 12;
  printf("%d", min(x,y));
  printf("\n");
  x = x*13;
  printf("x is now: %d\n", x);
  printf("%d", min(x,y));
  printf("\n");
  return 0;
}
