#include <iostream>
#include <version>  // for __cpp_lib_syncbuf
#if defined(__cpp_lib_syncbuf)
#include <syncstream>
#else
#include "osyncstream_compat.h"  // Apple's libc++ ships <syncstream> without implementing std::osyncstream.
#endif
#include <thread>

#define sync_cout std::osyncstream(std::cout)

thread_local int val = 0;

void setValue(int newval) { val = newval; }

void printValue() { sync_cout << val << ' '; }

void multiplyByTwo(int arg) {
    // The thread_local value is set and multiplied by 2
    setValue(arg);
    val *= 2;
    printValue();
}

int main() {
    val = 1;  // Value in main thread

    // Each thread set its own value
    std::thread t1(multiplyByTwo, 1);
    std::thread t2(multiplyByTwo, 2);
    std::thread t3(multiplyByTwo, 3);

    t1.join();
    t2.join();
    t3.join();

    std::cout << val << std::endl;

    return 0;
}