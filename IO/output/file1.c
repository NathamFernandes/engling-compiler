


int main() {
int i = 0;
inicio_enquanto_1:
if (!(i < 5)) goto fim_enquanto_1;
i++;
if (i == 2) {
goto inicio_enquanto_1;
};
if (i == 4) {
goto fim_enquanto_1;
};

goto inicio_enquanto_1;
fim_enquanto_1: ;;
};
