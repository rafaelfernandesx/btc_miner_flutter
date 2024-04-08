#include <unistd.h>

#ifdef __cplusplus
extern "C" {
#endif

__attribute__((visibility("default")))
char* minerHeader(const char* headerHex, const char* targetHex);

__attribute__((visibility("default")))
char * calculateHashPerSeconds();


__attribute__((visibility("default")))
intptr_t sum_long_running(intptr_t a, intptr_t b);

#ifdef __cplusplus
}
#endif