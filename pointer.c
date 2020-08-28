#include <stdio.h>
#include <stdlib.h>

void m1(int a){
  a = 16;
}

void m2(int *a){
  *a = 42;
}

int main() {
  int x = 11;
  m2(&x);
  m1(x);
  printf("%d\n", x); //prints out 42
  return 0;
}
