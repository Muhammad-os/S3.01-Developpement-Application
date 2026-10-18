# Journal de bord - Mousa MOHAMMAD

*Ce document retrace mon implication, mes tâches et mes apprentissages tout au long de la SAÉ.*

---

## Période 1 : Semaine du 11 au 18 octobre 2026

### Objectifs de la semaine
L'enjeu principal de cette première semaine était de poser des fondations solides pour l'équipe : préparer un environnement de développement sécurisé, multi-plateforme, et débuter le travail de rédaction des premiers livrables.

### Travail réalisé
*   **Mise en place de l'infrastructure technique :** 
    *   Au lieu d'utiliser une simple installation locale, j'ai pris l'initiative de configurer un environnement **Docker** (`docker-compose.yml` et `Dockerfile`). Cela garantit à tous les membres du groupe d'avoir exactement le même serveur (Apache/PHP 8.2 et PostgreSQL 15).
*   **Architecture et Sécurité :** 
    *   J'ai structuré le projet selon le modèle MVC en créant un dossier `public/` et un dossier `src/` pour empêcher les failles d'inclusion.
    *   J'ai configuré la protection des mots de passe de la base de données en créant un fichier `.env` bloqué par Git, et un `.env.example` partagé pour l'équipe.
*   **Gestion du code source :**
    *   Création de scripts d'automatisation PowerShell pour générer l'arborescence du projet.
    *   Synchronisation réussie avec l'équipe (gestion des `pull`, `commit` et `push`).
*   **Rédaction de documentation :**
    *   Rédaction du Livrable 3 en justifiant nos choix technologiques (PostgreSQL plutôt que MariaDB, utilisation du JS sans utilisation de jQuery, etc.).

### Difficultés rencontrées et Solutions
*   *Difficulté :* Problème de chemins introuvables (`DirectoryNotFoundException`) lors de la création des fichiers de configuration Docker dans PowerShell.
*   *Solution :* J'ai adapté le script pour forcer la création des sous-dossiers parents (via `mkdir -Force`) avant d'y injecter les fichiers.
