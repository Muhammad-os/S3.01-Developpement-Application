# Livrable 4 : Objectif du site

## 1 – Le but de l’application

L’objectif principal de ce projet est de développer un système d’information sur le cinéma et l’audiovisuel. On va pour cela exploiter les données présentes sur IMDb. 
Ce ne sera pas un simple affichage de ces données brutes mais il proposera également des informations calculées et croisées, permettant aux utilisateurs de découvrir des liens entre les films et les séries comme des acteurs en commun, une date de sortie commune...
Dans un second temps, pour enrichir notre base, nous prévoyons de fusionner ces données IMDb avec d'autres sources d'informations secondaires.

## 2 – Le public visé
Notre application s'adresse à un public assez large, mais on peut distinguer trois profils principaux :

1. **Le grand public :** Des personnes qui cherchent simplement des informations classiques sur un film, une série ou le casting d'une œuvre.

2. **Les cinéphiles passionnés :** Des utilisateurs plus exigeants qui vont vraiment profiter des fonctionnalités de recherche avancée et de rapprochement pour découvrir des liens précis entre différents films ou acteurs.

3. **Les professionnels du cinéma :** Des personnes qui ont besoin d'exploiter la base de données pour extraire des statistiques ou faire des recherches très spécifiques sur l'industrie.

Pour cibler au mieux notre interface, nous définirons ces profils de manière beaucoup plus détaillée un peu plus tard dans le projet, grâce à la création de "personas" prévus pour le livrable 9.

## 3 – Les particularités du site
Pour répondre aux exigences du projet, notre application intégrera plusieurs fonctionnalités clés qui vont au-delà d'un simple affichage de base de données :

* **Consultation fluide des données :** Le site proposera des fiches détaillées dédiées aux œuvres (films, séries) et aux professionnels (acteurs, réalisateurs). La navigation sera pensée pour passer facilement d'une fiche à l'autre.

* **Moteurs de recherche performants :** Outre une recherche simple classique, nous développerons une recherche avancée. Celle-ci permettra de filtrer les résultats et intégrera un algorithme de recherche approximative pour corriger ou tolérer les erreurs de frappe des utilisateurs.

* **Fonctions d'analyse et de croisement :** L'utilisateur pourra sélectionner deux entités (deux films ou deux personnes) pour faire ressortir leurs points communs, comme lister les acteurs qui ont joué dans deux films spécifiques. Le site implémentera également un algorithme basé sur la théorie des graphes. Il sera capable de calculer et d'afficher la chaîne de relations la plus courte reliant deux personnes ou deux films (par exemple, relier deux acteurs via les films dans lesquels ils ont tourné).

* **La sécurité dès la conception (Security by Design) :** La protection des données est une priorité. L'application intégrera des mesures strictes telles que l'utilisation de requêtes préparées (PDO) pour empêcher les injections SQL, et des protections contre les failles XSS. De plus, afin de simplifier la gestion légale liée au RGPD, nous avons fait le choix délibéré de ne collecter aucune donnée personnelle sur nos utilisateurs.
