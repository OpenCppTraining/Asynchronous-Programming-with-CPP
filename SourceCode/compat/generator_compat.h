#pragma once

// Neither Apple's libc++ nor upstream LLVM's libc++ ship <generator> yet.
// This is a minimal single-pass coroutine generator covering the subset of
// std::generator<T> used in this book: co_yield of a value, and iteration
// via begin()/end() or a range-based for loop.
#if __has_include(<generator>)
#include <generator>
#else
#include <coroutine>
#include <exception>
#include <utility>

namespace std {

template <typename T>
class generator {
   public:
    struct promise_type {
        T current_value{};
        std::exception_ptr exception;

        generator get_return_object() { return generator{handle_type::from_promise(*this)}; }
        std::suspend_always initial_suspend() { return {}; }
        std::suspend_always final_suspend() noexcept { return {}; }
        std::suspend_always yield_value(T value) {
            current_value = std::move(value);
            return {};
        }
        void return_void() {}
        void unhandled_exception() { exception = std::current_exception(); }
    };

    using handle_type = std::coroutine_handle<promise_type>;

    struct iterator {
        handle_type handle;

        iterator& operator++() {
            handle.resume();
            if (handle.done()) {
                handle = nullptr;
            }
            return *this;
        }
        const T& operator*() const { return handle.promise().current_value; }
        bool operator==(const iterator& other) const { return handle == other.handle; }
        bool operator!=(const iterator& other) const { return handle != other.handle; }
    };

    explicit generator(handle_type h) : handle_(h) {}
    generator(generator&& other) noexcept : handle_(std::exchange(other.handle_, nullptr)) {}
    generator(const generator&) = delete;
    generator& operator=(const generator&) = delete;

    ~generator() {
        if (handle_) {
            handle_.destroy();
        }
    }

    iterator begin() {
        if (handle_) {
            handle_.resume();
            if (handle_.promise().exception) {
                std::rethrow_exception(handle_.promise().exception);
            }
            if (handle_.done()) {
                return iterator{nullptr};
            }
        }
        return iterator{handle_};
    }

    iterator end() { return iterator{nullptr}; }

   private:
    handle_type handle_;
};

}  // namespace std
#endif
