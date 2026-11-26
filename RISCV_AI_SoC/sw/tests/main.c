#include <stdint.h>
#define DATA_mmio (*(volatile uint32_t *)0x10000000)
#define ID_mmio (*(volatile uint32_t *)0x10000004)
#define data_sw (*(volatile uint8_t *)0x10000001)

int sumar(int a, int b){
    return a+b;


    }

int g = 0x12345678;
int main (void){

    int errores = 0;
 // Leer ID

    if (ID_mmio!=0xC0FFEE01)
        errores++;

 //Escribir un valor de Data y leerlo

    
    DATA_mmio=0xA5A5A5A5;
    if (DATA_mmio != 0xA5A5A5A5)
        errores++;

//Escribir un byte suelto en data
  
data_sw=0x11;
    if (DATA_mmio != 0xA5A511A5)
    errores++;

//Usar la RAM como datos y pila

    if (g!= 0x12345678)
        errores++;



    int x=5;
    int z=6;
    int resultado= sumar(x,z);
    
    if (resultado!= 11)
        errores++;

    if (errores!=0)
        DATA_mmio=0x0000BAD0 + errores;
    else DATA_mmio=0x0000600D;

    while(1);


}