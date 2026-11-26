#include <stdio.h>
#include <math.h>



int main() {
int i = 0;
inicio_loop_1:
if (!(i < 10)) goto fim_loop_1;
printf("%s%d%s", "i: ", i, "\n");
i++;

goto inicio_loop_1;
fim_loop_1: ;;
};
