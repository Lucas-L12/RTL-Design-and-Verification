def leer(fichero):
    with open(fichero) as f:
        return [int(l, 16) for l in f if l.strip()]

def palabras(b):
    assert len(b) % 4 == 0
    return [b[i] | b[i+1] << 8 | b[i+2] << 16 | b[i+3] << 24
            for i in range(0, len(b), 4)]

def escribir(nombre, datos, fichero, guardia):
    with open(fichero, "w") as f:
        f.write(f"// Generado desde un .mem. No editar a mano.\n")
        f.write(f"#ifndef {guardia}\n#define {guardia}\n\n#include <stdint.h>\n\n")
        f.write(f"static const uint32_t {nombre}[{len(datos)}] = {{\n")
        for i in range(0, len(datos), 4):
            f.write("    " + ", ".join(f"0x{w:08x}" for w in datos[i:i+4]) + ",\n")
        f.write("};\n\n#endif\n")

escribir("imagen",  palabras(leer("image.mem")),           "imagen.h",  "IMAGEN_H")
escribir("esperado", palabras(leer("expected_output.mem")), "esperado.h", "ESPERADO_H")