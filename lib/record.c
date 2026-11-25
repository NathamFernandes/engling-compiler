#include "record.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

record *createRecord(char *code, Tipo *type) {
    record *rec = (record *) malloc(sizeof(record));
    if (rec != NULL) {
        rec->code = code;
        rec->type = type;
        rec->formato = NULL;
        rec->args_end = NULL;
    }
    return rec;
}

void freeRecord(record *rec) {
    if (rec == NULL) return;
    free(rec->code);
    liberar_tipo(rec->type);

    if (rec->formato != NULL) free(rec->formato);
    if (rec->args_end != NULL) free(rec->args_end);
    
    free(rec);
}

char * cat(char * s1, char * s2, char * s3, char * s4, char * s5) {
  int tam;
  char * output;

  tam = strlen(s1) + strlen(s2) + strlen(s3) + strlen(s4) + strlen(s5)+ 1;
  output = (char *) malloc(sizeof(char) * tam);
  
  if (!output){
    printf("Allocation problem. Closing application...\n");
    exit(0);
  }
  
  sprintf(output, "%s%s%s%s%s", s1, s2, s3, s4, s5);
  
  return output;
}