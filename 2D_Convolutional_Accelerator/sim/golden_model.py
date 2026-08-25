import numpy as np
from torchvision import datasets
import matplotlib.pyplot as plt


def sobel_kernel() -> np.ndarray:
    return np.array([[-1, 0, 1],
                      [-2, 0, 2],
                      [-1, 0, 1]], dtype=np.int8)


def convolve2d_int8(image: np.ndarray, kernel: np.ndarray) -> np.ndarray:
    # np.ndarray: tipo de dato de numpy para cálculo numérico eficiente,
    # todos sus elementos son del mismo tipo, permite operaciones aritméticas
    # elemento a elemento sin bucles manuales.
    """
    Convolución 2D manual, modo "valid" (sin padding).
    image:  array 2D (H, W)
    kernel: array 2D (kh, kw)
    return: array 2D (H-kh+1, W-kw+1), acumulador ancho (int32 o superior)
    """
    H, W = image.shape
    kh, kw = kernel.shape
    # .shape es un atributo de numpy que devuelve una tupla con las
    # dimensiones: (nº filas, nº columnas)

    out_h = H - kh + 1
    out_w = W - kw + 1

    # 1. Crea el array de salida, tamaño (out_h, out_w), tipo int32, lleno de ceros
    output = np.zeros((out_h, out_w), dtype=np.int32)

    # 2. Bucle sobre cada posición de salida (i recorre filas, j recorre columnas)
    for i in range(out_h):
        for j in range(out_w):

            # 3. Extrae la "ventana" de la imagen que coincide con esa posición
            #    (un trozo de tamaño kh×kw empezando en (i, j))
            ventana = image[i:i+kh, j:j+kw]

            # 4. Multiplica elemento a elemento por el kernel, suma todo,
            #    y guarda el resultado en output[i, j]
            output[i, j] = (ventana.astype(np.int32) * kernel.astype(np.int32)).sum()

    return output


def quantize_int8(x):
    scale = np.abs(x).max() / 127
    # Hacemos que el máximo sea mapeado justo al límite del rango (127)
    q = np.clip(np.round(x / scale), -128, 127).astype(np.int8)
    # Recortamos en el rango que nos convenga (clip) y redondeamos
    return q


def export_mem(array: np.ndarray, filepath: str) -> None:
    """
    Exporta un array int8 a un archivo .mem legible por $readmemh:
    un valor hexadecimal de 2 dígitos por línea, en orden fila por fila.
    """
    # 1. Aplana el array 2D a 1D
    array1d = array.flatten()

    # 2. Convierte cada valor a su representación sin signo (complemento a dos)
    array1duint8 = array1d.astype(np.uint8)

    # 3. Escribe el archivo, una línea por valor, en hex de 2 dígitos
    with open(filepath, "w") as f:
        for valor in array1duint8:
            f.write(format(valor, "02x") + "\n")


if __name__ == "__main__":
    test_set = datasets.MNIST(root="mnist_data", train=False, download=True)
    imagen_pil, etiqueta = test_set[0]
    image = np.array(imagen_pil)
    kernel = sobel_kernel()
    print(image.shape, image.dtype)
    print("Dígito:", etiqueta)

    image_q = quantize_int8(image)
    result_conv = convolve2d_int8(image_q, kernel)
    
    scale_out = np.abs(result_conv).max() / 127
    print("scale de salida:", scale_out)
    
    result_quantize = quantize_int8(result_conv)

    # plt.subplot(1, 2, 1)
    # plt.imshow(image, cmap="gray")
    # plt.title(f"Entrada (dígito {etiqueta})")

    # plt.subplot(1, 2, 2)
    # plt.imshow(result_quantize, cmap="gray")
    # plt.title("Salida (Sobel, cuantizada)")

    # plt.show()

    export_mem(image_q, "image.mem")
    export_mem(kernel, "kernel.mem")
    export_mem(result_quantize, "expected_output.mem")