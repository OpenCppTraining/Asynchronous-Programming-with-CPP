#include <boost/asio.hpp>
#include <iostream>

int main() {
    boost::asio::io_context io_context;

    // io_context::post()/dispatch() were member functions in older
    // Boost.Asio; they have since been removed, so use the free function
    // form instead.
    boost::asio::post(io_context, [] { std::cout << "This will always run asynchronously.\n"; });

    boost::asio::dispatch(io_context, [] { std::cout << "This might run immediately or be queued.\n"; });

    io_context.run();
    return 0;
}
