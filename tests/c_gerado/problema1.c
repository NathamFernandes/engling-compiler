#include "runtime.h"




int main() {
int c;
float x;
float y;
printf("%s", "insira os valores: \n");
scanf("%d%f%f", &c, &x, &y);
float final = pow(x, 2) - y + c;
printf("%f", final);
};
