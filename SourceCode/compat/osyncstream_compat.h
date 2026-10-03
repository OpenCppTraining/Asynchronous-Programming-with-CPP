#pragma once

// std::osyncstream fallback for standard libraries that don't implement it
// (e.g. Apple's libc++, which ships a <syncstream> header without defining
// osyncstream). Only include this when __cpp_lib_syncbuf is undefined — see
// the call sites, which choose between <syncstream> and this header.
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
