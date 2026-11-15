#!/bin/bash

set -e

cd "$(dirname "$0")/../../.."

mode="${1:-test}"

echo "Début de la mise à jour IMDb..."

./livrables/livrable05/scripts/telecharger_imdb.sh

./livrables/livrable05/scripts/importer_imdb.sh "$mode"

echo "Mise à jour terminée !"


