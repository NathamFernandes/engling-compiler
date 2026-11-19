#ifndef RECORD_H
#define RECORD_H

#include "tipos.h"

typedef struct record {
    char *code;
    Tipo *type;
} record;

record *createRecord(char *code, Tipo *type);
void freeRecord(record *rec);

char * cat(char *, char *, char *, char *, char *);

#endif