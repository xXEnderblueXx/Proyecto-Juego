#!/usr/bin/env python
import os
import sys

env = SConscript("godot_cpp/SConstruct")

# Configuración para que encuentre tus archivos .h y .cpp
env.Append(CPPPATH=["src/", "godot_cpp/include/", "godot_cpp/gen/include/"])
env.Append(LIBPATH=["godot_cpp/bin/"])

# Forzar el uso de MinGW si estás en Windows (para evitar conflictos con Visual Studio)
if os.name == "nt":
    env["use_mingw"] = True

# Buscar todos los archivos .cpp en la carpeta src
sources = Glob("src/*.cpp")

if env["platform"] == "windows":
    # Nombre de tu librería final (puedes cambiar 'juegoyare' por lo que quieras)
    library = env.SharedLibrary(
        target="bin/juegoyare",
        source=sources,
    )
else:
    library = env.SharedLibrary(
        target="bin/juegoyare",
        source=sources,
    )

Default(library)