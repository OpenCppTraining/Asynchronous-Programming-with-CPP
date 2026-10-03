#include <boost/asio.hpp>
#include <chrono>
#include <iostream>
#include <version> // for __cpp_lib_syncbuf
#if defined(__cpp_lib_syncbuf)
#include <syncstream>
#else
#include "osyncstream_compat.h" // Apple's libc++ ships <syncstream> without implementing std::osyncstream.
#endif
#include <thread>
#include <vector>

#define sync_cout std::osyncstream(std::cout)

using namespace std::chrono_literals;

void background_task(int task_id) {
  boost::asio::post([task_id]() {
    sync_cout << "Task " << task_id << " is being handled in thread "
              << std::this_thread::get_id() << std::endl;
    std::this_thread::sleep_for(2s);
    sync_cout << "Task " << task_id << " complete.\n";
  });
}

int main() {
  boost::asio::io_context io_context;
  auto work_guard = boost::asio::make_work_guard(io_context);

  std::jthread io_context_thread([&io_context]() { io_context.run(); });

  const int num_threads = 4;
  std::vector<std::jthread> threads;
  for (int i = 0; i < num_threads; ++i) {
    background_task(i);
  }

  std::this_thread::sleep_for(5s);
  work_guard.reset();

  return 0;
}
