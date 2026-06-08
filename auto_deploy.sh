#!/bin/bash
#
# auto_deploy.sh - Script d'automatisation du deploiement (TP DevOps UCAD)
#
# Etapes automatisees :
#   1. Verifier que git, node et npm sont installes
#   2. Cloner (ou mettre a jour) un depot GitHub
#   3. Installer les dependances
#   4. Lancer les tests unitaires
#   5. Demarrer l'application (en arriere-plan, avec sauvegarde du PID)
#
# Ameliorations (questions 1.3 du TP) :
#   1) L'URL du depot est passee en parametre
#   2) Fonction de log avec horodatage
#   3) Application lancee en arriere-plan + PID sauvegarde dans un fichier
#
# Usage :
#   ./auto_deploy.sh <URL_DU_DEPOT> [NOM_DOSSIER]
# Exemple :
#   ./auto_deploy.sh https://github.com/votre-nom/votre-app.git mon_app

set -e  # Arrete le script a la premiere erreur non geree

# ---------------------------------------------------------------------------
# Couleurs pour l'affichage
# ---------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'   # No Color (reset)

# ---------------------------------------------------------------------------
# Amelioration 2 : fonction de log avec horodatage
# ---------------------------------------------------------------------------
# Chaque message est prefixe par la date/heure et un niveau (INFO/OK/ERREUR),
# et ecrit a la fois a l'ecran et dans un fichier deploy.log.
LOG_FILE="deploy.log"

log() {
  local level="$1"      # INFO, OK ou ERREUR
  local message="$2"
  local color="$NC"
  case "$level" in
    OK)     color="$GREEN" ;;
    ERREUR) color="$RED" ;;
    INFO)   color="$YELLOW" ;;
  esac
  local timestamp
  timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
  # Affichage colore a l'ecran
  echo -e "${color}[${timestamp}] [${level}] ${message}${NC}"
  # Trace sans couleur dans le fichier de log
  echo "[${timestamp}] [${level}] ${message}" >> "$LOG_FILE"
}

# ---------------------------------------------------------------------------
# Amelioration 1 : URL du depot passee en parametre
# ---------------------------------------------------------------------------
REPO_URL="$1"
PROJECT_DIR="${2:-mon_app}"   # 2e argument optionnel, "mon_app" par defaut

if [ -z "$REPO_URL" ]; then
  log "ERREUR" "Usage : $0 <URL_DU_DEPOT> [NOM_DOSSIER]"
  exit 1
fi

log "INFO" "=== Deploiement automatique ==="
log "INFO" "Depot : $REPO_URL"
log "INFO" "Dossier cible : $PROJECT_DIR"

# ---------------------------------------------------------------------------
# Etape 1 : verification des dependances
# ---------------------------------------------------------------------------
for outil in git node npm; do
  if ! command -v "$outil" >/dev/null 2>&1; then
    log "ERREUR" "$outil requis mais non installe. Abandon."
    exit 1
  fi
done
log "OK" "git, node et npm sont presents."

# ---------------------------------------------------------------------------
# Etape 2 : clonage ou mise a jour du depot
# ---------------------------------------------------------------------------
if [ -d "$PROJECT_DIR" ]; then
  log "INFO" "Le dossier $PROJECT_DIR existe deja. Mise a jour (git pull)..."
  cd "$PROJECT_DIR"
  git pull
else
  log "INFO" "Clonage du depot..."
  git clone "$REPO_URL" "$PROJECT_DIR"
  cd "$PROJECT_DIR"
fi

# ---------------------------------------------------------------------------
# Etape 3 : installation des dependances
# ---------------------------------------------------------------------------
log "INFO" "Installation des dependances (npm install)..."
npm install

# ---------------------------------------------------------------------------
# Etape 4 : tests unitaires
# ---------------------------------------------------------------------------
log "INFO" "Lancement des tests (npm test)..."
# On desactive temporairement 'set -e' pour recuperer le code de sortie des tests
set +e
npm test
TEST_RESULT=$?
set -e

if [ $TEST_RESULT -ne 0 ]; then
  log "ERREUR" "Echec des tests. Deploiement interrompu."
  exit 1
fi
log "OK" "Tests passes avec succes."

# ---------------------------------------------------------------------------
# Etape 5 + Amelioration 3 : demarrage en arriere-plan + sauvegarde du PID
# ---------------------------------------------------------------------------
PID_FILE="app.pid"

# Si une instance precedente tourne encore, on l'arrete proprement
if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
  OLD_PID="$(cat "$PID_FILE")"
  log "INFO" "Arret de l'instance precedente (PID $OLD_PID)..."
  kill "$OLD_PID"
fi

log "INFO" "Demarrage de l'application en arriere-plan..."
# nohup + & : l'app continue meme apres la fermeture du terminal
# Sa sortie est redirigee vers app.out, et son PID stocke dans app.pid
nohup npm start > app.out 2>&1 &
echo $! > "$PID_FILE"

log "OK" "Application demarree (PID $(cat "$PID_FILE")). Logs : app.out"
log "INFO" "Pour l'arreter : kill \$(cat $PROJECT_DIR/$PID_FILE)"
