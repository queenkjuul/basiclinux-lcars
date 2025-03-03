#include <stdio.h>		/* fopen, fclose, asprintf, FILE, EOF, ... */
#include <string.h>		/* For strstr() */
#include <malloc.h>		/* free() */

void usage() {
  fprintf(stderr, 
	  "usage: doc2png [file ...]\n"
	  "\n"
	  "doc2png extracts PNG files from a MS Word doc file.\n"
	  "It does this in a very ugly way which might not always work.\n"
	  );
  exit(2);
}

void die(char *s) {
  perror(s);
  exit(1);
}

void writepng(FILE *fin, char *docfilename, int num) {
  FILE *fout;
  char *filename=NULL;
  char header[] = {0211, 'P', 'N', 'G', '\0'};
  char footer[] = {'I', 'E', 'N', 'D', 0xAE, 'B', '`', 0x82, '\0'};
  char last[9] = "        ";	/* bytes last seen (to search for footer) */

  int c;			/* input char */
  int i;			/* generic loop variable */
  char *p;			/* generic character position */

  /* Lop off the last occurence of .doc in the filename.  */
  /* E.g., "Flyer June1.doc" -> "Flyer June1" */
  if (filename) free(filename);	/* This should never happen  */
  asprintf(&filename, docfilename);
  p = strstr(filename, ".doc");
  if (p != NULL) {    
    while(strstr(p+1, ".doc")) p=strstr(p+1, ".doc");
    *p = '\0';
  }  
  if (filename) free(filename);	/* Free from the previous asprintf */
  asprintf(&filename, "%s-%02d.png", filename, num);
  fout=fopen(filename, "w");
  if (fout == NULL) {
    perror(filename);
    return;
  }

  printf("Extracting %s\n", filename);



  /* Output the header we consumed in main() */
  fprintf(fout, header);

  /* Copy the file byte by byte until the footer */
  while ((c=fgetc(fin)) != EOF && strcmp(last, footer)) {

    /* Copy the byte  */
    fputc(c, fout);

    /* Update the string of last seen bytes */
    for (i=0; i<7; i++) {
      last[i]=last[i+1];
    }
    last[7]=(char)c;
  }

  if (fclose(fout) != 0) die("FILE *fout");
}


int main(int argc, char *argv[])
{
  FILE *fp;
  char *filename = NULL;
  int c;
  int count=0;			/* Number of png files written out */

  if (argc == 1) usage();

  argv++;
  argc--;
  while (argc > 0) {
    filename=*argv;

    fp = fopen(filename, "r");
    if (fp == NULL) {
      perror(filename);
      argv++;			/* Next file */
      argc--;
      continue;
    }

    /* Read file, look for PNG header */
    while ((c=fgetc(fp)) != EOF) {
      if (c != 0211) continue;
      c=fgetc(fp); if (c!='P') continue;
      c=fgetc(fp); if (c!='N') continue;
      c=fgetc(fp); if (c!='G') continue;
    
      writepng(fp, filename, count++);
    }

    fclose(fp);

    argv++;			/* Next file */
    argc--;
  }

  return 0;
}
