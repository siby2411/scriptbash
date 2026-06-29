#!/bin/bash
LOG_DIR="$HOME/logs_apps"
mkdir -p $LOG_DIR

echo "🧹 Nettoyage des processus..."
pkill -9 python3
pkill -9 cloudflared
sleep 2

# Fonction de lancement
lancer() {
    local path=$1
    local port=$2
    local name=$3

    if [ -d "$path" ]; then
        cd "$path"
        echo "🚀 Lancement de $name sur port $port..."
        # Lancer Django en arrière-plan
        nohup python3 manage.py runserver 0.0.0.0:$port > "$LOG_DIR/$name.log" 2>&1 &
        
        # Attendre que le port soit bien ouvert
        sleep 5
        
        # Lancer le tunnel Cloudflare
        nohup cloudflared tunnel --url http://127.0.0.1:$port > "$LOG_DIR/tunnel_$name.log" 2>&1 &
        echo "✅ $name lancé avec tunnel."
    else
        echo "❌ Dossier introuvable : $path"
    fi
}

# --- LANCEMENT ---
lancer "/root/analyse_medicale" 5003 "analyses"
lancer "/root/cabinet_radiologie" 5004 "radiologie"
lancer "/root/clinique_dentaire" 5005 "dentaire"

echo "⏳ Attente de 15 secondes pour génération des liens..."
sleep 15

echo -e "\n--- VOS LIENS CLOUDFLARE ---"
# Affiche uniquement les URLs trouvées
grep -h 'https://[-a-z0-9.]*.trycloudflare.com' $LOG_DIR/tunnel_*.log | uniq
