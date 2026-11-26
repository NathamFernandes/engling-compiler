# Projeto

## Para rodar

### Buildar compilador

```bash
$ make
```
### Compilar aquivo .nan para .c && rodar GCC no .c gerado

```bash
$ make compile problemaX.nan
```

### Rodar executável gerado

```bash
$ ./build/bin/problemaX
```

## Features

### Features obrigatórias

- [ ] Implementação da atribuição e declaração para o restantes dos tipos

- Vetor
Pode ser feito estaticamente ou dinamicamente

### Features opcionais

- [ ] Fazer com que variáveis de mesmo tipo possam ser declaradas na mesma linha

Atualmente, só pode:

```
inteiro x;
inteiro y;
inteiro z;
char a;
```

Ideal: 

```
inteiro x, y, z;
char a;
```

- [ ] Fazer regra sintática e semântica do "faca-enquanto"

Atualmente, não pode, mas seria o ideal ter. Não tem nem a regra no parser:

```
faca {
    instrucoes
} enquanto (expressao)
```



