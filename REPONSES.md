# Réponses aux questions — TP Automatisation DevOps

**Auteur :** Aminata Diouf
**UCAD — Département Informatique — 2025/2026**

---

## Partie 1 — Script shell (`auto_deploy.sh`)

### Question 1 — Accepter l'URL du dépôt en paramètre
Le script lit l'URL via le premier argument de la ligne de commande (`$1`) et le nom
du dossier via le second (`$2`, avec `mon_app` comme valeur par défaut) :

```bash
REPO_URL="$1"
PROJECT_DIR="${2:-mon_app}"

if [ -z "$REPO_URL" ]; then
  log "ERREUR" "Usage : $0 <URL_DU_DEPOT> [NOM_DOSSIER]"
  exit 1
fi
```

Utilisation : `./auto_deploy.sh https://github.com/babyamina/tp-devops-pong.git mon_app`

### Question 2 — Fonction de log avec horodatage
Une fonction `log()` affiche chaque message avec la date/heure, un niveau
(INFO / OK / ERREUR) et une couleur, et écrit aussi une trace dans `deploy.log` :

```bash
log() {
  local level="$1"; local message="$2"
  local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
  echo -e "[${timestamp}] [${level}] ${message}"
  echo "[${timestamp}] [${level}] ${message}" >> "$LOG_FILE"
}
```

Exemple de sortie : `[2026-06-08 12:50:56] [OK] Tests passes avec succes.`

### Question 3 — Lancer l'application en arrière-plan et sauvegarder le PID
On utilise `nohup ... &` pour détacher le processus du terminal, puis `$!`
(PID du dernier processus lancé) que l'on enregistre dans `app.pid` :

```bash
nohup npm start > app.out 2>&1 &
echo $! > app.pid
```

Pour arrêter l'application : `kill $(cat app.pid)`.
Le script vérifie aussi qu'une ancienne instance n'est pas déjà en cours avant de
démarrer (via `kill -0`), ce qui évite de lancer deux serveurs en double.

---

## Partie 2 — GitHub Actions (`.github/workflows/ci.yml`)

### Travail demandé 1 & 2 — Application "pong" + fichier ci.yml
Une petite API Express répond `pong` sur la route `GET /ping` (`app.js`), testée
par `app.test.js`. Le workflow `ci.yml` se déclenche à chaque `push` (et `pull_request`)
sur `main`, installe les dépendances et exécute les tests.

### Travail demandé 3 — Ne déployer que si les tests passent
Le workflow est découpé en **deux jobs**. Le job `docker` dépend du job `build-and-test`
grâce au mot-clé `needs`. Si les tests échouent, le job Docker ne démarre jamais :

```yaml
docker:
  needs: build-and-test
  if: github.ref == 'refs/heads/main' && github.event_name == 'push'
```

### Travail demandé 4 (Avancé) — Déploiement via SSH
On pourrait ajouter un job de déploiement qui se connecte à un serveur en SSH et y
met à jour l'application. Exemple de principe :

```yaml
deploy:
  needs: build-and-test
  runs-on: ubuntu-latest
  steps:
    - uses: appleboy/ssh-action@v1.0.3
      with:
        host: ${{ secrets.SSH_HOST }}
        username: ${{ secrets.SSH_USER }}
        key: ${{ secrets.SSH_PRIVATE_KEY }}
        script: |
          cd /var/www/mon_app
          git pull
          npm install --omit=dev
          pm2 restart mon_app
```

La clé privée SSH et l'adresse du serveur sont stockées dans les **secrets** GitHub.

---

## Partie 3 — Terraform (questions de réflexion)

### Quels sont les avantages de l'IaC par rapport à une configuration manuelle ?
- **Reproductibilité** : la même infrastructure peut être recréée à l'identique
  autant de fois que nécessaire (dev, test, prod), sans erreur humaine.
- **Versionnement** : le code d'infrastructure est suivi dans Git (historique,
  revues de code, retour arrière possible).
- **Rapidité et automatisation** : créer/détruire des dizaines de serveurs en une
  commande, au lieu de cliquer manuellement dans une console.
- **Documentation vivante** : le fichier `.tf` décrit exactement l'infrastructure,
  il sert de documentation toujours à jour.
- **Cohérence** : évite les différences subtiles entre environnements
  (le fameux « ça marche sur ma machine »).

### Comment intégrer Terraform dans un pipeline CI/CD ?
On ajoute des étapes Terraform dans le pipeline (GitHub Actions, GitLab CI...) :
1. `terraform init` — initialise les providers.
2. `terraform plan` — calcule les changements ; on l'exécute souvent sur les
   *pull requests* pour relire l'impact avant de fusionner.
3. `terraform apply -auto-approve` — applique réellement les changements, en
   général **uniquement** sur la branche `main` après validation des tests.

Les identifiants du cloud (clés AWS, etc.) sont fournis via les **secrets** du
pipeline, et le fichier d'état (`.tfstate`) est stocké sur un *backend distant*
partagé (ex. bucket S3) pour que tout le pipeline travaille sur le même état.

### Quelles précautions prendre avec les fichiers `.tfstate` ?
- **Ne jamais le committer dans Git** : il peut contenir des données sensibles
  (mots de passe, IP, clés). On l'ajoute au `.gitignore`.
- **Le stocker sur un backend distant sécurisé** (S3 + chiffrement, Terraform Cloud...)
  plutôt qu'en local, pour le partager en équipe.
- **Activer le verrouillage (state locking)** (ex. via DynamoDB) pour éviter que
  deux personnes modifient l'état en même temps et le corrompent.
- **Sauvegarder / versionner l'état**, car le perdre signifie que Terraform ne sait
  plus quelles ressources il gère.
