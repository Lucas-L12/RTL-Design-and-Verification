#include <stdint.h>
#include "imagen.h"
#include "esperado.h"

#define DATA_mmio   (*(volatile uint32_t *)0x10000000)

#define ACC_START   (*(volatile uint32_t *)0x20000000)
#define ACC_STATUS  (*(volatile uint32_t *)0x20000004)
#define ACC_IN      ((volatile uint32_t *)0x20000400)
#define ACC_OUT     ((volatile uint32_t *)0x20000800)

#define DONE_BIT    0x1
#define ERROR_BIT   0x4

int main(void)
{
    int errores = 0;

    /* 1. Cargar la imagen en la memoria de entrada del acelerador */
    for (int i = 0; i < 196; i++)
        ACC_IN[i] = imagen[i];

    /* 2. Arrancar */
    ACC_START = 1;

    /* 3. Esperar a DONE */
    while ((ACC_STATUS & DONE_BIT) == 0)
        ;

    /* El acelerador no debe haber marcado ningun acceso ilegal */
    if (ACC_STATUS & ERROR_BIT)
        errores++;

    /* 4. Comparar la salida con el resultado esperado */
    for (int i = 0; i < 169; i++)
        if (ACC_OUT[i] != esperado[i])
            errores++;

    if (errores > 15)
        errores = 15;               /* tb_top espera un solo digito hexadecimal */

    if (errores == 0)
        DATA_mmio = 0x0000600D;
    else
        DATA_mmio = 0x0000BAD0 + errores;

    while (1)
        ;
}