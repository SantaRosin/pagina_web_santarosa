#!/bin/bash

# ============================================================
#   SCRIPT DE ACTUALIZACIÓN - pagina_web_santarosa
#   Uso: Doble clic o ejecutar en Git Bash
# ============================================================

REPO="C:/Users/BenjaminLangBustos/OneDrive - SERVICIO LOCAL DE EDUCACION PUBLICA SANTA ROSA/Equipo Estudio, Monitoreo y Datos - General/05_Datos_SR/00_Data_Lake/pagina_web_santarosa"

echo "=================================================="
echo "  ACTUALIZANDO PAGINA WEB SANTA ROSA"
echo "  $(date '+%d/%m/%Y %H:%M:%S')"
echo "=================================================="

# --- Ir al repositorio ---
cd "$REPO" || { echo "ERROR: No se encontró la carpeta del repositorio"; exit 1; }

# --- Eliminar lock si existe (por si GitHub Desktop lo dejó) ---
if [ -f ".git/index.lock" ]; then
    echo "⚠️  Eliminando index.lock residual..."
    rm -f ".git/index.lock"
fi

# --- Verificar y corregir LFS para HTMLs ---
if grep -q "\*.html filter=lfs" .gitattributes 2>/dev/null; then
    echo ""
    echo "⚠️  Detectado: HTMLs en LFS. Migrando a Git normal..."

    # Quitar regla LFS del .gitattributes
    sed -i '/\*.html filter=lfs/d' .gitattributes
    echo "   → Regla LFS eliminada de .gitattributes"

    # Desactivar tracking LFS para HTMLs
    git lfs untrack "*.html"

    # Migrar archivos de LFS a Git normal
    echo "   → Migrando archivos (esto puede tardar varios minutos)..."
    git lfs migrate export --include="*.html" --everything
    if [ $? -ne 0 ]; then
        echo "ERROR al migrar HTMLs desde LFS."
        exit 1
    fi
    echo "   ✅ HTMLs migrados correctamente a Git normal"
fi

# --- Traer cambios remotos ---
echo ""
echo "📥 Trayendo cambios remotos (pull)..."
git pull origin main --rebase
if [ $? -ne 0 ]; then
    echo "ERROR en git pull. Revisa tu conexión o conflictos."
    exit 1
fi

# --- Agregar TODOS los archivos nuevos o modificados ---
echo ""
echo "📦 Agregando todos los archivos modificados..."
git add .

# --- Ver cuántos archivos cambiaron ---
CAMBIOS=$(git diff --cached --name-only | wc -l)
echo "   → $CAMBIOS archivo(s) con cambios detectados"

if [ "$CAMBIOS" -eq 0 ]; then
    echo ""
    echo "✅ No hay cambios nuevos. Todo está actualizado."
    exit 0
fi

# --- Mostrar qué archivos se van a subir ---
echo ""
echo "📋 Archivos a subir:"
git diff --cached --name-only

# --- Commit con fecha automática ---
FECHA=$(date '+%d/%m/%Y %H:%M')
git commit -m "Actualización automática: $FECHA"
if [ $? -ne 0 ]; then
    echo "ERROR en git commit."
    exit 1
fi

# --- Push a GitHub ---
echo ""
echo "🚀 Subiendo cambios a GitHub..."
git push origin main --force
if [ $? -ne 0 ]; then
    echo "ERROR en git push. Revisa tu conexión o autenticación."
    exit 1
fi

echo ""
echo "=================================================="
echo "  ✅ TODO LISTO - Cambios subidos correctamente"
echo "  $(date '+%d/%m/%Y %H:%M:%S')"
echo "=================================================="
