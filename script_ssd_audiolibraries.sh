#!/bin/bash

# 🔹 Lancer en sudo
# sudo ./script_ssd_audiolibraires.sh

# Chemin du disque externe
DEST="/Volumes/kDrive/AudioLibraries"
BACKUP_RAR="/Volumes/kDrive/AudioLibrariesBackup.rar"

# Crée le dossier racine si inexistant
mkdir -p "$DEST"

# Tableau des librairies à déplacer depuis Application Support
libs=(
  "Avid"                            # 10 go
  "iZotope"                         # 1 go
  "Kilohearts"                      # 2.6 go
  "Native Instruments"              # 3.3 go
  "Propellerhead Software"          # 3.8 go
  "Spectrasonics"
  "UVISoundBanks"                   # 50 go
)

# Dossiers “hors Application Support” (ex: Arturia)
special_libs=(
  "/Library/Arturia"                # 50 go
)

# 🔹 Vérifie si RAR est installé
if ! command -v rar &> /dev/null
then
    echo "Erreur : 'rar' n'est pas installé. Installe-le via Homebrew : brew install rar"
    exit 1
fi

# 🔹 Crée un backup RAR de tous les dossiers existants
echo "Création du backup RAR de toutes les librairies..."
RAR_INPUT=()

# Librairies classiques
for lib in "${libs[@]}"; do
    SRC="/Library/Application Support/$lib"
    if [ -d "$SRC" ]; then
        RAR_INPUT+=("$SRC")
    fi
done

# Dossiers spéciaux
for SRC in "${special_libs[@]}"; do
    if [ -d "$SRC" ]; then
        RAR_INPUT+=("$SRC")
    fi
done

if [ ${#RAR_INPUT[@]} -gt 0 ]; then
    rar a -r "$BACKUP_RAR" "${RAR_INPUT[@]}"
    echo "Backup créé : $BACKUP_RAR ✅"
else
    echo "Aucune librairie trouvée pour le backup ⏭️"
fi

# 🔹 Déplace chaque librairie classique et crée le symlink
for lib in "${libs[@]}"; do
  SRC="/Library/Application Support/$lib"
  DEST_LIB="$DEST/$lib"

  if [ -d "$SRC" ]; then
    echo "Déplacement de $lib..."
    mv "$SRC" "$DEST_LIB"
    echo "Création du symlink..."
    ln -s "$DEST_LIB" "$SRC"
    echo "$lib déplacé et symlink créé ✅"
  else
    echo "$lib non trouvé, skip ⏭️"
  fi
done

# 🔹 Déplace les dossiers spéciaux et crée le symlink
for SRC in "${special_libs[@]}"; do
  lib_name=$(basename "$SRC")
  DEST_LIB="$DEST/$lib_name"

  if [ -d "$SRC" ]; then
    echo "Déplacement de $lib_name..."
    mv "$SRC" "$DEST_LIB"
    echo "Création du symlink..."
    ln -s "$DEST_LIB" "$SRC"
    echo "$lib_name déplacé et symlink créé ✅"
  else
    echo "$lib_name non trouvé, skip ⏭️"
  fi
done

echo "Toutes les librairies ont été traitées."
