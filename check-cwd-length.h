#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

static _Bool check_cwd_length(int min_length) {
  char buf[4096];
  char* cwd = getcwd(buf, sizeof(buf));
  if (cwd && strlen(cwd) + 1 >= min_length) {
    return true;
  }
  fprintf(stderr, "This test needs a CWD with length %d but was only %ld: %s",
          min_length, (long)strlen(cwd) + 1, cwd);
  return false;
}
