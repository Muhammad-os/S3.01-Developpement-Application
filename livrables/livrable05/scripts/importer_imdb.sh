#!/bin/bash

set -e
set -o pipefail

mode="${1:-test}"

if [ "$mode" != "test" ] && [ "$mode" != "complet" ]; then
    echo "Utilisation : ./scripts/importer_imdb.sh [test|complet]"
    exit 1
fi

mkdir -p logs

echo "Préparation des tables..."

docker compose exec -T db psql -U root -d films \
    -v ON_ERROR_STOP=1 -f - < livrables/livrable05/scripts/sql/prepare_import.sql

if [ ! -f logs/importations.csv ]; then
    echo "date,mode,fichier,lignes,duree_secondes" > logs/importations.csv
fi

for nom in title.basics name.basics title.principals title.crew title.ratings title.episode title.akas
do
    fichier="data/imdb/$nom.tsv.gz"

    table="import_${nom//./_}"

    if [ ! -s "$fichier" ]; then
        echo "Fichier absent ou vide : $fichier"
        exit 1
    fi

    echo "Importation de $nom ($mode)..."

    debut=$(date +%s)

    if [ "$mode" = "test" ]; then

        set +o pipefail

        gzip -dc "$fichier" 2>/dev/null | head -n 201 | tail -n +2 | \
            docker compose exec -T db psql -U root -d films \
            -v ON_ERROR_STOP=1 -c "\copy $table FROM STDIN"

        set -o pipefail

    else

        gzip -dc "$fichier" | tail -n +2 | \
            docker compose exec -T db psql -U root -d films \
            -v ON_ERROR_STOP=1 -c "\copy $table FROM STDIN"

    fi

    fin=$(date +%s)

    duree=$((fin - debut))

    lignes=$(docker compose exec -T db psql -U root -d films \
        -At -c "SELECT COUNT(*) FROM $table;")

    echo "$(date '+%Y-%m-%d %H:%M:%S'),$mode,$nom,$lignes,$duree" >> logs/importations.csv

    echo "$lignes lignes importées en $duree secondes."
done

echo "Importation dans les tables intermédiaires terminée."

echo "Transformation des données en cours..."

debut=$(date +%s)

docker compose exec -T db psql -U root -d films \
    -v ON_ERROR_STOP=1 \
    --single-transaction \
    -f - < livrables/livrable05/scripts/sql/transform_import.sql

fin=$(date +%s)
duree=$((fin - debut))

lignes=$(docker compose exec -T db psql -U root -d films \
    -At -c "SELECT COUNT(*) FROM title_basics;")

echo "$(date '+%Y-%m-%d %H:%M:%S'),$mode,transformation,$lignes,$duree" >> logs/importations.csv

echo "Transformation terminée !"
echo "$lignes titres presents dans la base."
echo "Duree : $duree secondes."

