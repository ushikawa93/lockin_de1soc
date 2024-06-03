#!/bin/bash

# Directorio raíz donde se encuentran las carpetas con los programas
ROOT_DIR="."

# Encuentra y ejecuta todos los Makefiles en las subcarpetas
find "$ROOT_DIR" -name Makefile -execdir make \;

echo "Todos los Makefiles han sido ejecutados."