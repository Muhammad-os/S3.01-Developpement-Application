# Livrable 3 : Plateforme de développement

*Note : Ce document est un journal de bord évolutif. Il sera mis à jour régulièrement tout au long de la SAÉ pour refléter l'évolution de notre environnement de travail.*

## Configuration initiale

- **Serveur Web Apache 2 avec module `rewrite` activé**
  - *Pourquoi :* Environnement requis par le sujet. Le module `rewrite` est utile pour gérer nos URL proprement.
  - *Comment :* Activé via la commande `a2enmod rewrite` dans notre configuration.

- **PHP 8.2 avec l'extension `pdo_pgsql`**
  - *Pourquoi :* Langage imposé. L'extension est indispensable pour connecter PHP à la base de données.
  - *Comment :* Installée directement via notre `Dockerfile`.

- **Base de données PostgreSQL version 15**
  - *Pourquoi :* Autorisé par le sujet. C'est le SGBD que l'équipe maîtrise le mieux, ce qui nous aidera pour les requêtes de recherche complexes.
  - *Comment :* Instanciée automatiquement par Docker.

- **Utilisation de JavaScript Vanilla (au lieu de jQuery)**
  - *Pourquoi :* Permet de garder un code léger et sans dépendances externes. Cette décision pourra toutefois évoluer vers l'utilisation de jQuery ou d'une autre bibliothèque si les besoins de l'interface se complexifient à l'avenir.

## Ajout du 18 octobre 2026 (Architecture, Environnement et Sécurité)

- **Séparation du code et découverte de l'architecture MVC**
  - *Pourquoi :* En cherchant comment sécuriser notre application avec un point d'entrée unique, nos recherches nous ont menés vers le standard **MVC** (Modèle-Vue-Contrôleur). Cette découverte nous a permis de structurer logiquement nos dossiers en séparant la base de données, l'affichage et la logique.
  - *Comment :* Apache a été reconfiguré pour pointer uniquement sur le sous-dossier `public/`, ce qui rend nos dossiers de code invisibles aux visiteurs.

- **Déploiement de l'environnement via Docker**
  - *Pourquoi :* Répond à l'exigence de portabilité du sujet. Cela garantit que le serveur fonctionne exactement de la même manière sur l'ordinateur de chaque membre du groupe.
  - *Comment :* Création d'un `docker-compose.yml` qui permet de tout lancer en une seule commande.

- **Sécurisation des identifiants via un fichier d'environnement**
  - *Pourquoi :* Empêcher la fuite de nos mots de passe de base de données sur le dépôt partagé.
  - *Comment :* Nous avons mis à disposition un modèle nommé `.env.example` dans le dossier `config/`. Chaque membre du groupe doit le copier localement sur son ordinateur pour créer son propre fichier caché `.env`. Ce vrai fichier `.env` est intentionnellement bloqué par Git (via `.gitignore`) afin de ne jamais être publié en ligne.
