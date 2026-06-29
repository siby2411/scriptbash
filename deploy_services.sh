#!/bin/bash

# 1. Nettoyage de l'environnement
echo "Arrêt des services existants..."
pkill -9 php
service mariadb restart

# Définition des applications
# Format: "NomDossier:Port:DocumentRoot"
SERVICES=(
    "auto_mvc:8000:public"
    "agence_immo:8081:."
    "aviculture:8082:public"
    "omega_hotel_erp:8083:public"
)

echo "Démarrage des services..."

for service in "${SERVICES[@]}"; do
    IFS=":" read -r DIR PORT DOC_ROOT <<< "$service"
    
    if [ -d "/root/$DIR" ]; then
        echo "Lancement de $DIR sur le port $PORT (Root: $DOC_ROOT)..."
        # Lancement en arrière-plan avec le dossier cible correct
        cd /root/$DIR && nohup php -S 0.0.0.0:$PORT -t "$DOC_ROOT" > /dev/null 2>&1 &
    else
        echo "Erreur : Le dossier /root/$DIR n'existe pas."
    fi
done

echo "Tous les services sont lancés."
