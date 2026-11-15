é#!/bin/bash

set -e 

mkdir -p data/imdb
mkdir -p logs

if [ !  -f logs/telechargements.csv ]; then
	echo "date,fichier,taille_octets,duree_secondes" > logs/telechargements.csv
fi

for nom in title.basics name.basics title.principals title.crew title.ratings title.episode title.akas
do
	fichier="$nom.tsv.gz"
	url="https://datasets.imdbws.com/$fichier"

	debut=$(date +%s)

	echo "Téléchargement de $fichier..."

	curl -fL --retry 3 "$url" -o "data/imdb/$fichier.part"

	gzip -t "data/imdb/$fichier.part"

	mv "data/imdb/$fichier.part" "data/imdb/$fichier"

	fin=$(date +%s)

	duree=$((fin - debut))
	taille=$(wc -c < "data/imdb/$fichier" | tr -d '[:space:]')

	echo "$(date '+%Y-%m-%d %H:%M:%S'),$fichier,$taille,$duree" >> logs/telechargements.csv

	echo "Téléchargement terminé."
	echo "Durée : $duree secondes."
	echo "Taille : $taille octets."
	echo "-----------------------------"
done

echo "Tous les téléchargements sont terminés."
