#!/bin/bash

# lancer en sudo

# Chemin du disque externe
DEST="/Volumes/kDrive/AudioLibraries"
BACKUP_RAR="/Volumes/kDrive/AudioLibrariesBackup.rar"

# Crée le dossier racine si inexistant
mkdir -p "$DEST"

# Tableau des librairies à déplacer
libs=(
  "Avid"
  "D16 Group"
  "DS Audio"
  "iZotope"
  "Kilohearts"
  "Minimal"
  "Native Instruments"
  "Output"
  "Propellerhead Software"
  "Spectrasonics"
  "Sonic Academy"
  "UVI"
  "UVISoundBanks"
  "Waves"
)

# Vérifie si RAR est installé
if ! command -v rar &> /dev/null
then
    echo "Erreur : 'rar' n'est pas installé. Installe-le via Homebrew : brew install rar"
    exit 1
fi

# Crée un backup RAR de tous les dossiers existants
echo "Création du backup RAR de toutes les librairies..."
RAR_INPUT=()
for lib in "${libs[@]}"; do
    SRC="/Library/Application Support/$lib"
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

# Déplace chaque librairie et crée le symlink
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

echo "Toutes les librairies ont été traitées."
