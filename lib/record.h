#ifndef REGISTRO
#define REGISTRO

struct registro {
	   char * code; /* field for storing the output code */
	   char * opt1; /* field for another purpose */
};

typedef struct registro registro;
 
void freeRecord(registro *);
registro * createRecord(char *, char *);

#endif