#!/usr/bin/env bash
set -euo pipefail

echo "Limpiando..."
make clean

echo "Compilando..."
make

echo "Ejecutando..."
./TPS
