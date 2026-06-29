#!/bin/bash
echo "Arrêt des services..."
pkill -9 php
pkill -9 cloudflared
service mariadb restart
rm -f /tmp/tunnel_*.log

# Format: "Dossier:Port:DocRoot:NomAffichage"
SERVICES=(
    "auto_mvc:8000:public:AUTO_PRO"
    "agence_immo:8081:.:AGENCE_IMMO"
    "aviculture:8082:public:AVICULTURE"
    "omega_hotel_erp:8083:public:HOTEL_ERP"
    "auto_design:8004:auto_design/public:AUTO_DESIGN"
    "prospects:8005:.:PROSPECTS"
)

echo "Démarrage des services et tunnels..."

for service in "${SERVICES[@]}"; do
    IFS=":" read -r DIR PORT DOC_ROOT NOM <<< "$service"
    
    # Lancement PHP
    cd /root/$DIR && nohup php -S 127.0.0.1:$PORT -t "$DOC_ROOT" > /dev/null 2>&1 &
    
    # Lancement Cloudflare Tunnel
    echo "Lancement tunnel pour $NOM..."
    nohup cloudflared tunnel --url http://localhost:$PORT > /tmp/tunnel_$PORT.log 2>&1 &
    sleep 8
done

echo "--------------------------------------------------------"
echo "LISTE DES URLS CLOUDFLARE POUR VOS COLLABORATEURS :"
echo "--------------------------------------------------------"

for service in "${SERVICES[@]}"; do
    IFS=":" read -r DIR PORT DOC_ROOT NOM <<< "$service"
    URL=$(grep -o 'https://[-a-zA-Z0-9]*\.trycloudflare\.com' /tmp/tunnel_$PORT.log | tail -n 1)
    printf "%-15s : %s\n" "$NOM" "${URL:-URL en attente}"
done
echo "--------------------------------------------------------"
