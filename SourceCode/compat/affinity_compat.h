#pragma once

// Chapter_13's benchmarks pin worker threads to specific cores. The API for
// that is entirely OS-specific, so this branches on the target platform
// rather than any library/compiler feature.

#if defined(__APPLE__)
// macOS has no hard affinity API; thread_policy_set with THREAD_AFFINITY_POLICY
// is only a scheduler hint to co-locate threads sharing a tag, not a pin to a
// specific core.
#include <mach/mach.h>
#include <mach/thread_policy.h>
#include <pthread.h>

inline void set_affinity(int core) {
  if (core < 0) {
    return;
  }

  thread_affinity_policy_data_t policy{core};
  thread_policy_set(
      pthread_mach_thread_np(pthread_self()), THREAD_AFFINITY_POLICY,
      reinterpret_cast<thread_policy_t>(&policy), THREAD_AFFINITY_POLICY_COUNT);
}

#elif defined(__linux__)
#include <cstdio>
#include <cstdlib>
#include <pthread.h>
#include <sched.h>

inline void set_affinity(int core) {
  if (core < 0) {
    return;
  }

  cpu_set_t cpuset;
  CPU_ZERO(&cpuset);
  CPU_SET(core, &cpuset);
  if (pthread_setaffinity_np(pthread_self(), sizeof(cpu_set_t), &cpuset) != 0) {
    perror("pthread_setaffinity_np");
    exit(EXIT_FAILURE);
  }
}

#elif defined(_WIN32)
#include <windows.h>

inline void set_affinity(int core) {
  if (core < 0) {
    return;
  }

  SetThreadAffinityMask(GetCurrentThread(), static_cast<DWORD_PTR>(1) << core);
}

#else

inline void set_affinity(int) {}

#endif
