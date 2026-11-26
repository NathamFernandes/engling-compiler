#include <stdio.h>
#include <math.h>



int main() {
int total = 0;
{
    int i = 0;
inicio_1: ;
    if (!(i < 5)) goto fim_1;
    {
    if (i == 1) {
    goto inicio_1;
    };
    if (i == 3) {
    goto fim_1;
    };
    total++;
    }

continuar_1:
    i++;
    goto inicio_1;
fim_1: ;
};
{
    int i = 0;
inicio_3: ;
    if (!(i < 2)) goto fim_3;
    {
    total++;
    }
continuar_3:
    i++;
    goto inicio_3;
fim_3: ;
};
};
