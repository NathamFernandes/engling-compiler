#include <stdio.h>
#include <math.h>



int main() {
int numero = 0;
int intervalo_0_25 = 0;
int intervalo_26_50 = 0;
int intervalo_51_75 = 0;
int intervalo_76_100 = 0;
int total = 0;
scanf("%d", &numero);
inicio_enquanto_1:
if (!(numero >= 0)) goto fim_enquanto_1;
if (0 <= numero && numero <= 25) {
printf("%s", "oi");
};

goto inicio_enquanto_1;
fim_enquanto_1: ;;
printf("%s%d%s", "Total de números lidos: ", total, "\n");
printf("%s%d%s", "Total de números no intervalo [0, 25]: ", intervalo_0_25, "\n");
printf("%s%d%s", "Total de números no intervalo [26, 50]: ", intervalo_26_50, "\n");
printf("%s%d%s", "Total de números no intervalo [51, 75]: ", intervalo_51_75, "\n");
printf("%s%d%s", "Total de números no intervalo [76, 100]: ", intervalo_76_100, "\n");
};
