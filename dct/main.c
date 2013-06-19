#include <stdio.h>
#include <math.h>
#include <time.h>
#include <sys/time.h>

typedef unsigned long long ticks;

void _fdct(float m1[64], float m2[64], int n);
void _idct(float m1[64], float m2[64], int n);

float x[64]  __attribute__((aligned(0x1000))) = {
-16342,   2084, -10049,  10117,   2786,   -659,  -4905,  12975,
 10579,   8081, -10678,  11762,   6898,    444,  -6422, -15892,
-13388,  -4441, -11556, -10947,  16008,  -1779, -12481, -16230,
-16091,  -4001,   1038,   2333,   3335,   3512, -10936,   5343,
 -1612,  -4845, -14514,   3529,   9284,   9916,    652,  -6489,
 12320,   7428,  14939,  13950,   1290, -11719,  -1242,  -8672,
 11870,  -9515,   9164,  11261,  16279,  16374,   3654,  -3524,
 -7660,  -6642,  11146, -15605,  -4067, -13348,   5807, -14541, 
};

float y[64] __attribute__((aligned(0x1000))) = {
-541.156,  564.183, -3225.06,  1029.39,    880.5, -500.075, -619.409,  250.288,
-1115.78, -1001.23, -431.803,  161.758,  1364.75, -2246.93,  -1358.3, -2555.14,
 135.138,  213.742,  755.227,  -798.47, -511.912,  757.452, -328.224,  641.975,
 2911.69,  358.601,  451.503, -772.025,  1295.27,  1140.53, -301.878, -1709.05,
-1597.88, -2786.38,  767.095, -1646.88, -785.531, -787.608,  71.4126, -446.098,
 1035.58, -1972.48, -784.681, -1258.37,  469.222, -892.254,  1591.34, -245.704,
 -2021.4,  491.207,  460.276, -1841.76, -760.928, -700.527,  -766.29,  1317.45,
-480.216, -1925.16, -786.589,  2491.86,  304.856, -665.711, -30.9113,   152.51
};

static __inline__ ticks getticks(void)
{
     unsigned a, d;
     asm("cpuid");
     asm volatile("rdtsc" : "=a" (a), "=d" (d));

     return (((ticks)a) | (((ticks)d) << 32));
}
int n = 4;
int size = 8;
float in[64*3400] __attribute__((aligned(0x1000)));
float out[64*3400] __attribute__((aligned(0x1000)));

void test() {
    ticks begin, end;
    int k, i, j;
    for (k = 0; k < n; k++) {
        if (k % 2 == 0)
            continue;
        for (i = 0; i < size; i++) {
            for (j = 0; j < size; j++) {
                in[64*k + 8*i + j] = x[8*i+j];
                out[64*k + 8*i + j] = 0;
            }
        }
    }
    begin = getticks();
    _fdct(in, out, n);
    end = getticks();
        k = n - 1;
    for (k = 0; k < n; k++) {
        for (i = 0; i < size; i++) {
            for (j = 0; j < size; j++) {
                printf("%12.3f", out[64*k + 8*i + j]);
            }
            printf("\n");
        }
        printf("\n\n");
    }
    printf("fdct\t%Ld\n", (end - begin) / 1);
    begin = getticks();
    _idct(out, in, n);
    end = getticks();
        k = n - 1;
    for (k = 0; k < n; k++) {
        for (i = 0; i < size; i++) {
            for (j = 0; j < size; j++) {
                printf("%12.3f", in[64*k + 8*i + j]);
            }
            printf("\n");
        }
        printf("\n\n");
    }
    printf("idct\t%Ld\n", (end - begin) / 1);
}

float c[64];
float ct[64];

void generate_c() {
    int i, j;
    for (i = 0; i < size; i++) {
        for (j = 0; j < size; j++) {
            if (i == 0)
                c[8*i+j] = 1 / sqrtf(8.0);
            if (i > 0) {
                float cs = ((2 * j + 1) * i * M_PI) / 16;
                c[8*i+j] = 0.5 * cosf(cs);
            }
        }
    }
    for (i = 0; i < size; i++)
        for (j = 0; j < size; j++)
           ct[8*i+j] = c[8*j+i];
}


void print(float qq[64]) {
    int i, j;
    for (i = 0; i < size; i++) {
        for (j = 0; j < size; j++) {
            printf("%12.3f", qq[8*i+j]);
        }
        printf("\n");
    }
    printf("------------------------------------------------------------------------------------------------\n");
}

int main() {
    //generate_c();
    //print(c);
    //print(ct);
    test();
}
