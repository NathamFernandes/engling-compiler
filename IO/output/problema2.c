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
int numero = 0;
int intervalo_0_25 = 0;
int intervalo_26_50 = 0;
int intervalo_51_75 = 0;
int intervalo_76_100 = 0;
int total = 0;
scanf("%d", &numero);
inicio_enquanto_0: 
 if (!(numero >= 0)) goto fim_enquanto_0;
 { 
}
goto inicio_enquanto_0;
 fim_enquanto_0: ;;
printf("%s%d%s", "Total de números lidos: ", total, "\n");
printf("%s%d%s", "Total de números no intervalo [0, 25]: ", intervalo_0_25, "\n");
printf("%s%d%s", "Total de números no intervalo [26, 50]: ", intervalo_26_50, "\n");
printf("%s%d%s", "Total de números no intervalo [51, 75]: ", intervalo_51_75, "\n");
printf("%s%d%s", "Total de números no intervalo [76, 100]: ", intervalo_76_100, "\n");
};
