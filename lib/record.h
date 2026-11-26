#ifndef RECORD_H
#define RECORD_H

#include "semantica.h"

typedef struct record {
    char *code;
    Tipo *type;
    char *formato;
    char *args_end;
} record;

record *createRecord(char *code, Tipo *type);
void freeRecord(record *rec);

char * cat(char *, char *, char *, char *, char *);

#endif