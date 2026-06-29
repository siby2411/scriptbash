#!/bin/bash

# 1. Nettoyage total
echo "Arrêt des services..."
pkill -9 php
pkill -9 cloudflared
service mariadb restart
rm -f /tmp/tunnel_*.log

# 2. Définition des services
SERVICES=(
    "auto_mvc:8000:public:AUTO_PRO"
    "agence_immo:8081:.:AGENCE_IMMO"
    "aviculture:8082:public:AVICULTURE"
    "omega_hotel_erp:8083:public:HOTEL_ERP"
)

echo "Démarrage des services et tunnels (mode séquentiel)..."

for service in "${SERVICES[@]}"; do
    IFS=":" read -r DIR PORT DOC_ROOT NOM <<< "$service"
    
    # Lancement PHP
    cd /root/$DIR && nohup php -S 127.0.0.1:$PORT -t "$DOC_ROOT" > /dev/null 2>&1 &
    
    # Lancement Cloudflare Tunnel avec un délai pour laisser le temps à l'API de répondre
    echo "Lancement tunnel pour $NOM..."
    nohup cloudflared tunnel --url http://localhost:$PORT > /tmp/tunnel_$PORT.log 2>&1 &
    
    # Indispensable : attendre que le tunnel précédent soit bien enregistré
    sleep 8
done

echo "--------------------------------------------------------"
echo "LISTE DES URLS CLOUDFLARE GÉNÉRÉES :"
echo "--------------------------------------------------------"

for service in "${SERVICES[@]}"; do
    IFS=":" read -r DIR PORT DOC_ROOT NOM <<< "$service"
    # Lecture patiente du log
    URL=$(grep -o 'https://[-a-zA-Z0-9]*\.trycloudflare\.com' /tmp/tunnel_$PORT.log | tail -n 1)
    echo "$NOM : ${URL:-URL en attente ou erreur}"
done
echo "--------------------------------------------------------"
