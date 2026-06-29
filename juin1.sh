#!/bin/bash
echo "--------------------------------------------------------"
echo "🚀 DÉPLOIEMENT DE LA FLOTTE GLOBALE OMEGA SUITE 2026"
echo "--------------------------------------------------------"
service mariadb start

# 1. Lancement du Serveur Principal (Priorité 1)
# Utilisation de nohup pour éviter qu'il ne s'arrête si le shell se ferme
nohup php -S 0.0.0.0:8080 -t /root/shared/htdocs/apachewsl2026 > /dev/null 2>&1 &
echo "  -> [Port 8080] Serveur Principal : Lancé"

launch_php() {
    if [[ "$2" == "piece_auto" || "$2" == "report" ]]; then
        TARGET_DIR="/root/shared/htdocs/apachewsl2026/$2/public"
    else
        TARGET_DIR="/root/shared/htdocs/apachewsl2026/$2"
    fi
    
    php -S 0.0.0.0:$1 -t $TARGET_DIR > /dev/null 2>&1 &
    echo "  -> [Port $1] $2 : Lancé"
}

# --- PÔLES ET SERVICES ---
launch_php 8094 "ingenierie"
launch_php 8095 "banque"
launch_php 8098 "assurance"
launch_php 8096 "gp"
launch_php 8100 "pme"
launch_php 8101 "gestion_commerciale"
launch_php 8102 "ecommerce"
launch_php 8103 "gestion_ecommerciale"
launch_php 8104 "restau"
launch_php 8110 "auto"
launch_php 8111 "gestion_auto"
launch_php 8112 "piece_auto"
launch_php 8113 "o_garage"
launch_php 8114 "transport"
launch_php 8093 "gestion_pointage"
launch_php 8091 "gestion_ecole"
launch_php 8092 "pressing"
launch_php 8120 "clinique"
launch_php 8130 "report"
launch_php 8140 "centrediop"
launch_php 8144 "pharmacie"
launch_php 8141 "charcuterie1"
launch_php 8142 "foot"
launch_php 8143 "librairie"
launch_php 8150 "analyse_medicale"
launch_php 8151 "hotel"
launch_php 8153 "cabinet_radiologie"
launch_php 8154 "gestion_immobiliere"

# --- VAGUES FINALES ---
launch_php 8152 "portail"
launch_php 8155 "transit"
launch_php 8156 "agence_voyage"
launch_php 8157 "annuaire"
launch_php 8158 "fitness"
launch_php 8159 "pizzeria"
launch_php 8160 "scooter"
launch_php 8161 "cosmetique"
launch_php 8164 "offre_emploi"

echo "--------------------------------------------------------"
echo "🌐 TOUTES LES APPLICATIONS SONT LANCÉES"
