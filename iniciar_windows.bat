@echo off
chcp 65001 >nul
setlocal
REM Abre el panel de Historias Bot en el navegador y deja el bot funcionando.
REM Deja esta ventana abierta (puedes minimizarla). Si se cierra por un error, vuelve a arrancar a los 60 segundos.
cd /d "%~dp0"

REM ---- Busca un Python compatible: 3.11 a 3.14 de 64 bits (lo que necesita la voz Kokoro) ----
set "PY="
for %%V in (3.13 3.12 3.14 3.11) do (
  if not defined PY (
    py -%%V -c "import struct,sys; sys.exit(0 if struct.calcsize('P')==8 else 1)" >nul 2>nul && set "PY=py -%%V"
  )
)
if not defined PY (
  python -c "import struct,sys; v=sys.version_info[:2]; sys.exit(0 if (3,11)<=v<=(3,14) and struct.calcsize('P')==8 else 1)" >nul 2>nul && set "PY=python"
)
if not defined PY (
  echo.
  echo No encuentro un Python compatible. La voz del bot necesita Python 3.11, 3.12, 3.13 o 3.14 de 64 bits.
  echo.
  where python >nul 2>nul && (
    echo El Python que tienes ahora es:
    python -c "import sys,struct; print('   Python', sys.version.split()[0], '-', struct.calcsize('P')*8, 'bits')"
  )
  echo.
  echo Instala Python 3.13 de 64 bits desde https://www.python.org/downloads/windows/
  echo   - Elige "Windows installer (64-bit)".
  echo   - Marca "Add Python to PATH" y deja marcado "py launcher".
  echo   - No hace falta quitar el Python que ya tienes.
  echo Luego vuelve a abrir este archivo.
  echo.
  pause
  exit /b 1
)
echo Usando: %PY%

REM ---- Instala las librerias que falten (solo la primera vez o tras una actualizacion) ----
%PY% -c "import yaml, ruamel.yaml, requests, numpy, PIL, soundfile, kokoro_onnx" >nul 2>nul
if errorlevel 1 (
  echo Instalando las librerias del bot. La primera vez tarda unos minutos...
  %PY% -m pip install --upgrade pip >nul 2>nul
  %PY% -m pip install -r requirements.txt
  if errorlevel 1 (
    echo.
    echo No se pudieron instalar las librerias. Revisa el error de arriba.
    pause
    exit /b 1
  )
)

where ffmpeg >nul 2>nul
if errorlevel 1 (
  echo.
  echo AVISO: no se encuentra ffmpeg, que hace falta para montar los videos.
  echo Instalalo con:  winget install Gyan.FFmpeg
  echo y luego cierra y vuelve a abrir esta ventana.
  echo.
)

%PY% main.py panel
:bucle
echo El bot se ha detenido. Reiniciando en 60 segundos...
timeout /t 60 /nobreak >nul
%PY% main.py panel --sin-navegador
goto bucle
