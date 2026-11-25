#include <stdio.h>
#include <math.h>



int main() {
int c;
float x;
float y;
scanf("%d%f%f", &c, &x, &y);
float final = pow(x, 2) - y + c;
printf("%f", final);
};
