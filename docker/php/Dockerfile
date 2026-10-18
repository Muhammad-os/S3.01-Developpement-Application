# Màj du Dockerfile pour PSQL
FROM php:8.2-apache

# Activation de la réécriture d'URL
RUN a2enmod rewrite

# Installation des dépendances système pour PSQL
RUN apt-get update && apt-get install -y libpq-dev

# Installation de l'extension PHP
RUN docker-php-ext-install pdo pdo_pgsql

# Pour la sécurité, on force le serveur à pointer vers le dossier "public"
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
