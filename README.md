
## Structure du dépôt Git

```
data-science-student-performance/
│
├── code/                          # Scripts R d'analyse
│   ├── 00_setup.R                # Configuration initiale
│   ├── 01_import_check.R         # Import et vérification des données
│   ├── 02_descriptives.R         # Analyses descriptives
│   ├── 03_first_model.R          # Premier modèle
│   ├── 04_diagnostics.R          # Diagnostics du modèle
│   └── 05_final_model.R          # Modèle final
│
├── data/                          # Données du projet
│   ├── raw/                       # Données brutes
│   │   └── students.csv          # Fichier CSV source
│   ├── processed/                 # Données traitées
│   │   └── students_clean.rds    # Données nettoyées (format R)
│   └── README_data.md            # Documentation des données
│
├── outputs/                       # Résultats générés
│   ├── figures/                   # Graphiques et visualisations
│   │   ├── cooks_distance_m1.png
│   │   ├── correlation_matrix.png
│   │   ├── freq_lunch.png
│   │   ├── freq_parental_level_of_education.png
│   │   ├── freq_test_preparation_course.png
│   │   ├── hist_math_score.png
│   │   ├── hist_reading_score.png
│   │   ├── hist_residuals_m1.png
│   │   ├── hist_writing_score.png
│   │   ├── qqplot_residuals_m1.png
│   │   ├── residuals_vs_fitted_m1.png
│   │   ├── scatter_math_reading.png
│   │   ├── scatter_math_writing.png
│   │   └── studentized_residuals_m1.png
│   │
│   └── tables/                    # Tableaux de résultats
│       ├── anova_m1_vs_m1_quad.csv
│       ├── anova_m1_vs_mquad.csv
│       ├── correlation_matrix.csv
│       ├── descriptives_quantitative.csv
│       ├── diagnostics_m1_summary.txt
│       ├── final_model_fit.csv
│       ├── final_model_results.csv
│       ├── final_model_summary.txt
│       ├── first_10_rows.csv
│       ├── first_model_fit.csv
│       ├── first_model_results.csv
│       ├── first_model_summary.txt
│       ├── influential_points_cooks_m1.csv
│       ├── influential_points_summary.csv
│       ├── residuals_skew_kurt_m1.csv
│       ├── sensitivity_model_fit.csv
│       ├── sensitivity_model_results.csv
│       ├── studentized_residuals_m1.csv
│       └── vif_m1.csv
│
├── report/                        # Rapports et documentation
│   ├── Dossier_etape_1.pdf       # Rapport étape 1
│   ├── Dossier_final.md          # Rapport final (Markdown)
│   └── outputs/                   # Sorties du rapport
│       └── figures/               # Figures du rapport
│
├── renv/                          # Environnement R reproductible
│   ├── activate.R                # Script d'activation
│   ├── settings.json             # Paramètres renv
│   ├── staging/                   # Fichiers de staging
│   └── library/                   # Bibliothèques R installées
│       └── [bibliothèques système spécifiques]
│
├── .git/                          # Dépôt Git (répertoire caché)
│   ├── branches/                  # Branches Git
│   ├── hooks/                     # Hooks Git
│   ├── info/                      # Informations Git
│   ├── logs/                      # Journaux Git
│   ├── objects/                   # Objets Git
│   └── refs/                      # Références Git
│       ├── heads/                 # Références des branches locales
│       ├── remotes/               # Références des dépôts distants
│       │   └── origin/            # Dépôt distant origin
│       └── tags/                  # Tags Git
│
├── README.md                      # Documentation principale du projet
├── renv.lock                      # Verrouillage des versions des packages R
└── ARBORESCENCE.md               # Ce fichier (arborescence du projet)
```

## Description des répertoires principaux

### `/code`
Contient tous les scripts R pour l'analyse des données, organisés dans un ordre séquentiel (00 à 05).

### `/data`
- `raw/` : Données brutes non modifiées
- `processed/` : Données après traitement et nettoyage
- `README_data.md` : Documentation décrivant les données

### `/outputs`
Résultats générés par les scripts d'analyse :
- `figures/` : Graphiques et visualisations (PNG)
- `tables/` : Tableaux statistiques (CSV et TXT)

### `/report`
Rapports finaux et documentation :
- Documents PDF et Markdown
- Figures spécifiques aux rapports

### `/renv`
Gestion de l'environnement R pour la reproductibilité :
- `renv.lock` : Verrouillage des versions des packages
- `library/` : Bibliothèques R installées localement

### `/.git`
Répertoire du dépôt Git (caché) contenant :
- Historique des commits
- Branches et tags
- Configuration du dépôt

---