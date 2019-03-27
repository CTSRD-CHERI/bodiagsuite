#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <assert.h>
#include <stdlib.h>
#include <err.h>
#include <sysexits.h>
#include <fcntl.h>

#ifndef ACCESS_OFFSET
#error ACCESS_OFFSET not defined
#endif
#if ACCESS_OFFSET != 9 && ACCESS_OFFSET != 10 && ACCESS_OFFSET != 17 && ACCESS_OFFSET != 4105
#error "Invalid value for ACCESS_OFFSET"
#endif

int getSharedMem()
{
  // This was broken before: int id = shmget(IPC_PRIVATE, 10, 0xffffffff);
  // Note: the size is rounded up to the next page size so maybe should allocate 4096?
  int id = shmget(IPC_PRIVATE, 10, IPC_CREAT | IPC_EXCL | S_IRWXU);
  if (id == -1) {
    err(EX_OSERR, "shmget() failed");
  }
  struct shmid_ds temp;
  int ret = shmctl(id, IPC_STAT, &temp);
  if (ret == -1) {
    err(EX_OSERR, "shmctl(IPC_STAT) failed");
  }
  if (temp.shm_segsz != 10) {
    errx(EX_OSERR, "shared memory segment has wrong size %ld", (long)temp.shm_segsz);
  }
  return id;
}

void relSharedMem(int memID)
{
  struct shmid_ds temp;
  int ret = shmctl(memID, IPC_RMID, &temp);
  if (ret == -1) {
    err(EX_OSERR, "shmctl() failed");
  }
}

int main(int argc, char *argv[])
{
  int memIdent;
  char * buf;

  memIdent = getSharedMem();
  assert(memIdent != -1);

  buf = ((char *) shmat(memIdent, NULL, 0));
  if (buf == ((void*)-1)) {
    err(EX_OSERR, "shmat() failed");
  }
  assert(((int)buf) != -1);

  buf[ACCESS_OFFSET] = 'A';

  int ret = shmdt((void *)buf);
  if (ret != 0) {
    err(EX_OSERR, "shmdt() failed");
  }
  relSharedMem(memIdent);

  return 0;
}
