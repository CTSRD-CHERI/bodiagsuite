#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <assert.h>
#include <stdlib.h>
#include <err.h>
#include <sysexits.h>

int getSharedMem()
{
  int id = shmget(IPC_PRIVATE, 10, 0xffffffff);
  if (id == -1) {
    err(EX_OSERR, "shmget() failed");
  }
  return id;
}

void relSharedMem(int memID)
{
  struct shmid_ds temp;
  int err = shmctl(memID, IPC_RMID, &temp);
  if (err == -1) {
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

  /*  OK  */
  buf[ACCESS_OFFSET] = 'A';

  int err = shmdt((void *)buf);
  if (buf == ((void*)-1)) {
    err(EX_OSERR, "shmat() failed");
  }
  relSharedMem(memIdent);

  return 0;
}
