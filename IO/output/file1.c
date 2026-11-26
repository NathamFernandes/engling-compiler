#include <stdio.h>
#include <math.h>
const int LIMITE = 5;
const int DEBUG = 0;

typedef struct {
    int x;
    int y;
} Ponto;


int main() {
Ponto origem;
int i = 0;
int validos = 0;
int nota = 7;
int achou = 0;
if (!(nota > 8)) goto se_1_1;
{
validos = 3;
}
goto fim_se_1;
se_1_1: ;
if (!(nota == 7)) goto se_1_2;
{
validos = 2;
}
goto fim_se_1;
se_1_2: ;
{
validos = 1;
}
fim_se_1: ;;
if (!(DEBUG)) goto se_3_1;
{
validos = 0;
}
goto fim_se_3;
se_3_1: ;
fim_se_3: ;;
inicio_loop_1:
if (!(i < LIMITE)) goto fim_loop_1;
i++;
if (!(i == 2)) goto se_5_1;
{
goto inicio_loop_1;
}
goto fim_se_5;
se_5_1: ;
fim_se_5: ;;
if (!(i == 4)) goto se_7_1;
{
achou = 1;
goto fim_loop_1;
}
goto fim_se_7;
se_7_1: ;
fim_se_7: ;;

goto inicio_loop_1;
fim_loop_1: ;;
{
int j = 0;
inicio_loop_3: ;
if (!(j < 3)) goto fim_loop_3;
{
validos++;
}
continuar_3:
j++;
goto inicio_loop_3;
fim_loop_3: ;
};
{
int j = 0;
inicio_loop_5: ;
if (!(j < 3)) goto fim_loop_5;
{
int dobro = 0;
inicio_loop_7:
if (!(dobro < 2)) goto fim_loop_7;
dobro++;
validos++;

goto inicio_loop_7;
fim_loop_7: ;;
}
continuar_5:
j++;
goto inicio_loop_5;
fim_loop_5: ;
};
if (!(achou)) goto se_9_1;
{
nota = 9;
}
goto fim_se_9;
se_9_1: ;
fim_se_9: ;;
};
