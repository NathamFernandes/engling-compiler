#include <stdio.h>
#include <math.h>



int main() {
int total = 0;
{
int i = 0;
inicio_loop_1: ;
if (!(i < 5)) goto fim_loop_1;
{
if (i == 1) {
goto inicio_loop_1;
};
if (i == 3) {
goto fim_loop_1;
};
total++;
}
continuar_1:
i++;
goto inicio_loop_1;
fim_loop_1: ;
};
{
int i = 0;
inicio_loop_3: ;
if (!(i < 2)) goto fim_loop_3;
{
total++;
}
continuar_3:
i++;
goto inicio_loop_3;
fim_loop_3: ;
};
};
