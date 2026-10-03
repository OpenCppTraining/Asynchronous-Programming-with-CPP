#include <iostream>
#include <version> // for __cpp_lib_syncbuf
#if defined(__cpp_lib_syncbuf)
#include <syncstream>
#else
#include "osyncstream_compat.h" // Apple's libc++ ships <syncstream> without implementing std::osyncstream.
#endif
#include <thread>

#define sync_cout std::osyncstream(std::cout)

int main() {

  std::thread t1([]() {
    for (int i = 0; i < 100; ++i) {
      sync_cout << "1 " << "2 " << "3 " << "4 " << std::endl;
    }
  });

  std::thread t2([]() {
    for (int i = 0; i < 100; ++i) {
      sync_cout << "5 " << "6 " << "7 " << "8 " << std::endl;
    }
  });

  t1.join();
  t2.join();

  return 0;
}
