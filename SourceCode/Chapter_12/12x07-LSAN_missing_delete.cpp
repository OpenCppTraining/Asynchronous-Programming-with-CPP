#include <iostream>
#include <memory>
#include <string.h>

int main() {
  auto arr = new char[100];
  strcpy(arr, "Hello world!");
  std::cout << "String = " << arr << '\n';
  return 0;
}
