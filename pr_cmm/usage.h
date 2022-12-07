#pragma once

#include <iostream>
#include <cstdlib>
#include <string>

const std::string kHelp{"Este programa se esta desarrollando, la funcionalidades aceptadas hasta ahora son:\n"
                        "./copy [-a][-m] ruta/de/origen ruta/de/destino.\n"};
const std::string kError{"Opciones no encontradas.\nPruebe: ./cp --help para mas informacion\n"};
const std::string kErrorArgs{"Numero de argumentos excedido.\nPruebe: ./cp --help para mas informacion\n"};
void Usage (int, char*[]);