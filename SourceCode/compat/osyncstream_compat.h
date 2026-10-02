#pragma once

// Apple's libc++ ships a <syncstream> header but does not implement
// std::osyncstream (no __cpp_lib_syncbuf). This falls back to an equivalent
// built on a shared mutex when the real one isn't available.
#include <version>

#if defined(__cpp_lib_syncbuf)
#include <syncstream>
#else
#include <iostream>
#include <mutex>
#include <sstream>

namespace std {

class osyncstream : public std::ostringstream {
   public:
    explicit osyncstream(std::ostream& out) : out_(out) {}
    osyncstream(const osyncstream&) = delete;
    osyncstream& operator=(const osyncstream&) = delete;

    ~osyncstream() {
        static std::mutex mutex;
        std::lock_guard<std::mutex> lock(mutex);
        out_ << str();
        out_.flush();
    }

   private:
    std::ostream& out_;
};

}  // namespace std
#endif
