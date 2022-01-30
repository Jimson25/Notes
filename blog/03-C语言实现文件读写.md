### C语言实现文件读写

#### 一、字符读写

```c
void readCharFromFile(const char *fileName) {
    FILE *file = NULL;
    if ((file = fopen(fileName, "r")) == NULL) {
        printf("file not exist!");
        exit(1);
    }
    while (!feof(file)) {
        printf("read char: %c\n", fgetc(file));
    }
    fclose(file);
}

void writeCharToFile(const char *fileName) {
    FILE *file = NULL;
    char str;
    if ((file = fopen(fileName, "w+")) == NULL) {
        printf("file not exist!");
        exit(1);
    }
    while ((str = getchar()) != '#') {
        fputc(str, file);
    }
    fclose(file);
}
```

#### 二、字符串读写

```c
void readStrFromFile(const char *path) {
    FILE *file = NULL;
    if ((file = fopen(path, "r")) == NULL) {
        printf("file open field!");
        exit(1);
    }
    while (!feof(file)) {
        char str[8192];
        fgets(str, 8192, file);
        printf("%s", str);
    }
}


void writeStrToFile(char *str, const char *filePath) {
    FILE *file = NULL;
    if ((file = fopen(filePath, "a+")) == NULL) {
        printf("file open field!");
        exit(1);
    }
    if (NULL != str) {
        fputs(strcat(str, "\n"), file);
    }
    fclose(file);
}
```

#### 三、测试

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void writeCharToFile(const char *);

void readCharFromFile(const char *);

void writeStrToFile(char *str, const char *filePath);

void readStrFromFile(const char *path);

int main() {
    char *path = "D:\\test\\test.txt";

//    writeCharToFile(path);
//    readCharFromFile(path);
    char str[81920], ch = 0;
    scanf("%s", str);
    while ((ch = str[strlen(str) - 1]) != '#') {
        writeStrToFile(str, path);
        scanf("%s", str);
    }
    readStrFromFile(path);
    return 0;
}

```

