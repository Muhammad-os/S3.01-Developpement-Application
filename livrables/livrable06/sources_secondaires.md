# Livrable 6 : Présentation de sources secondaires de données

## Objectif
Le but de ce document est de présenter les sources de données complémentaires que nous utiliserons pour enrichir notre base de données principale (qui utilise les fichiers bruts d'IMDb).

## Source principale retenue : TMDB (The Movie Database)
Nous avons choisi d'utiliser l'API de **TMDB** comme source secondaire principale pour faire de l'agrégation de données. 

Les données brutes fournies par IMDb sont très complètes concernant les noms, les titres et les dates, mais elles ne contiennent aucun élément visuel. L'API de TMDB va nous permettre de récupérer des éléments essentiels pour l'affichage :
* Les affiches (posters) officielles des films et des séries.
* Les photos de profil des acteurs et des réalisateurs.
* Les synopsis (résumés des œuvres).
* Les liens vers les bandes-annonces.

L'ajout de TMDB rendra notre application web beaucoup plus visuelle et agréable à utiliser pour la consultation des fiches.

Pendant notre analyse, nous avons aussi identifié d'autres sources qui pourraient être pertinentes en bonus :
* **OMDb API :** Cette source permet de récupérer les notes données par la presse et les critiques (comme Metacritic par exemple).
* **Box Office Mojo :** Cette base est idéale pour extraire des informations financières (budget de réalisation, recettes au box-office), ce qui correspond aux besoins d'un public de professionnels du cinéma.

**Conclusion :** 
Pour la suite du projet et la fusion des données, nous nous concentrerons en priorité sur TMDB, car l'ajout d'images est la fonctionnalité qui apportera le plus de valeur ajoutée à l'interface de notre site.
