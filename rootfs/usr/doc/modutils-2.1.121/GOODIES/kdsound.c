#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/msg.h>
#define CONFIG_KERNELD
#include <linux/kerneld.h>

#define MSIZE 1024
#define KERNELD_SOUND 300

/*
 * Copyright (C) 1995, 1996  Bjorn Ekwall <bj0rn@blox.se>
 *
 * See the file "COPYING" for your rights (GPL).
 *
 * This is an extra kerneld that just listens for sound requests,
 * i.e. message type 300.
 * This number was randomly chosen, as being a round number > 255.
 *
 * That means that it can run concurrently with the "normal" kerneld,
 * so that we can test the funtionality before folding it in with
 * the other kerneld requests.
 *
 * Start "kdsound" as: "/sbin/kdsound &"
 */

int
main(argc, argv)
int argc;
char **argv;
{
	struct kerneld_msg *msgp;
	int status;
	int qid;
	char *soundparam;

	qid = msgget(IPC_PRIVATE, 0600 | IPC_KERNELD);
	if (qid < 0) {
		perror("kdsound");
		exit(1);
	}

	msgp = (struct kerneld_msg *)malloc(sizeof(struct kerneld_msg) + MSIZE);

	while (1) {
		status = msgrcv(qid, (struct msgbuf *)msgp,
			sizeof(long) + MSIZE, KERNELD_SOUND, MSG_NOERROR);
		if (status > 0) {
#ifdef NEW_KERNELD_PROTOCOL /* using new extended kerneld message format */
			struct oldkerneld_msg {
				long mtype;
				long id;
				char text[1];
			};

			if (msgp->version == 2) {
				if (msgp->pid != 0) {
					char triggerpid[30];
					sprintf(triggerpid, "KERNELD_TRIGGER=%d", msgp->pid);
					putenv(triggerpid);
				}
				soundparam = msgp->text;
			}
			else
				soundparam = ((struct oldkerneld_msg *)msgp)->text;
#else
			soundparam = msgp->text;
#endif
			if (sound_pid > 0) {
				kill(
			}
			if ((sound_pid = fork()) == 0) {
				execlp("/bin/sh", "sh", "/sbin/do_sound",
					soundparam, 0);
				exit(0);
			}
		}
	}
}
