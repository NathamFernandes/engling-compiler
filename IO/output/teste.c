#include <stdio.h>
#include <stdlib.h>
#include <math.h>

typedef struct {
    void *dados;
    int tamanho;
} Vetor;

Vetor criar_vetor(int tam, size_t elem_size) {
    Vetor v;
    v.dados = calloc(tam, elem_size);
    v.tamanho = tam;
    return v;
}




int main() {
Vetor v = criar_vetor(3, sizeof(int));
((int*)(v).dados)[0] = 10;
((int*)(v).dados)[1] = 20;
int tam = (v).tamanho;
Vetor m = criar_vetor(2, sizeof(Vetor));
((Vetor*)(m).dados)[0] = criar_vetor(2, sizeof(double));
((double*)(((Vetor*)(m).dados)[0]).dados)[1] = 7.500000;
printf("%d%s%lf%s%d", ((int*)(v).dados)[0], " ", ((double*)(((Vetor*)(m).dados)[0]).dados)[1], " ", tam);
};
