#include "record.h"
#include <stdlib.h>

record *createRecord(char *code, Tipo *type) {
    record *rec = (record *) malloc(sizeof(record));
    if (rec != NULL) {
        rec->code = code;
        rec->type = type;
    }
    return rec;
}

void freeRecord(record *rec) {
    if (rec == NULL) return;
    free(rec->code);
    liberar_tipo(rec->type);
    free(rec);
}