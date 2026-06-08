# TP Automatisation DevOps — UCAD 2025/2026

Petit projet illustrant l'automatisation DevOps autour d'une API Node.js/Express
qui répond `pong`. Le TP couvre trois parties : script shell, CI/CD GitHub Actions,
et Infrastructure as Code avec Terraform.

**Auteur :** Aminata Diouf

## Structure du projet

```
tp-devops/
├── app.js                      # API Express : GET /ping -> "pong"
├── server.js                   # Démarrage du serveur HTTP
├── app.test.js                 # Test unitaire (node --test + supertest)
├── package.json                # Dépendances et scripts npm
├── auto_deploy.sh              # Partie 1 : script bash d'automatisation
├── .github/workflows/ci.yml    # Partie 2 : pipeline CI/CD GitHub Actions
├── Dockerfile                  # Image Docker de l'application (bonus)
├── main.tf                     # Partie 3 : Infrastructure as Code (Terraform)
├── REPONSES.md                 # Réponses aux questions du TP
└── README.md                   # Ce fichier
```

## Prérequis
- Node.js 18+ et npm
- Git
- (Optionnel) Docker, Terraform

---

## Partie 1 — Script d'automatisation (bash)

Le script `auto_deploy.sh` vérifie les outils, clone/met à jour un dépôt, installe
les dépendances, lance les tests, puis démarre l'application en arrière-plan.

```bash
# Donner les droits d'exécution (une seule fois)
chmod +x auto_deploy.sh

# Lancer : ./auto_deploy.sh <URL_DU_DEPOT> [NOM_DOSSIER]
./auto_deploy.sh https://github.com/aminata21diouf-creator/-tp-devops-pong.git mon_app
```

Fichiers produits : `deploy.log` (journal horodaté), `app.pid` (PID de l'app),
`app.out` (sortie de l'app). Pour arrêter l'application : `kill $(cat mon_app/app.pid)`.

### Lancer l'application seule
```bash
npm install
npm start          # http://localhost:3000/ping  ->  pong
```

### Lancer les tests seuls
```bash
npm test
```

---

## Partie 2 — Pipeline CI/CD (GitHub Actions)

Le workflow `.github/workflows/ci.yml` se déclenche automatiquement à chaque `push`
ou `pull_request` sur `main` :
1. **Job `build-and-test`** : installe les dépendances et exécute les tests.
2. **Job `docker`** : construit l'image Docker et la pousse sur Docker Hub —
   uniquement si les tests ont réussi (`needs: build-and-test`) et sur `main`.

### Secrets à configurer (Settings → Secrets and variables → Actions)
- `DOCKER_USERNAME` : nom d'utilisateur Docker Hub
- `DOCKER_PASSWORD` : token d'accès Docker Hub

Le suivi des exécutions se fait dans l'onglet **Actions** du dépôt GitHub.

---

## Partie 3 — Infrastructure as Code (Terraform)

Le fichier `main.tf` décrit une instance AWS EC2 qui installe Nginx automatiquement.

```bash
terraform init                  # initialise les providers
terraform plan                  # prévisualise les changements
terraform apply -auto-approve   # crée l'infrastructure
terraform destroy               # détruit l'infrastructure
```

> Nécessite un compte AWS et des identifiants (`aws configure`). Le fichier d'état
> `terraform.tfstate` ne doit jamais être versionné (voir `.gitignore`).

---

## Réponses aux questions
Voir le fichier [REPONSES.md](REPONSES.md).
