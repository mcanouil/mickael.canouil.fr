---
title: Longitudinal Genetic Modelling
summary: |
    Revisiting Associations of SNPs Associated with Blood Fasting Glucose in Normoglycemic Individuals.
abstract: |
    New statistical methods need to be proposed as an alternative to the current cross-sectional design predominantly used in genome-wide association studies (GWAS). When longitudinal (repeated) measures of a trait are available, an efficient modelling of the temporal trajectories is expected to increase statistical power to detect genetic loci associated with that trait.  
    Using genotypes assayed with the Metabochip DNA arrays (Illumina) from 4,500 subjects recruited in the French cohort D.E.S.I.R. (Données Épidémiologiques sur le Syndrome d’Insulino-Résistance), we re-examine published GWAS findings for some confirmed loci associated with fasting plasma glucose (FPG).  
    We compared several approaches to test the SNP main effect, on the one hand, and to test the interaction SNP-by-time effect, on the other hand. For the former, we compared five methods: linear regression models using only baseline measures or using the average of measures across all time-points, Two-Step approach with random intercept, Generalised Estimating Equations (GEE) and Linear Mixed Model (LMM); while for the latter we compared Two-Step approach with random slope, Conditional Two-Step, GEE and LMM with interaction term.  
    Type I error and power were computed using permutations and resampling procedures on the full dataset for the SNP effect, and using numerical simulations for the interaction effect. Across all models tested, the type I error was not inflated. In contrast, power analysis sometimes showed an increased statistical power for the baseline approach compared to methods dealing with repeated measures of FPG. We provide mathematical conditions showing why this counterintuitive situation might happen.  
    In the context of large GWAS with millions of imputed SNPs and when repeated measures are available for exploration, implementing methods which approximate a full longitudinal model seems at present the most efficient and fastest way to identify genetic associations without major loss in power. More importantly, these approximate methods run much faster than the full modelling approaches like GEE or LMM and could help picking the most associated SNPs for further testing in full models.

all_day: false

date: "2016-02-11T14:00:00Z"
# date_end: "2019-01-21
publishDate: "2016-02-11"

event: |
    Statistical Methods for Post Genomic Data (SMPGD)
# event_url:
location: Université de Lille - Cité Scientifique
address:
  # street: 450 Serra Mall
  city: Villeneuve d'Ascq
  postcode: '59650'
  country: France

featured: false
image:
  focal_point: Right

projects: []

tags:
  - joint modelling
  - survival analysis
  - longitudinal biomarker
  - statistical power study
  - genetics
  - type 2 diabetes
  - glycaemia
  - english
  - research

links:
- icon: file-alt
  icon_pack: far
  name: Slides
  url: https://github.com/mcanouil/slides/raw/main/20160211-longitudinal-genetic-modelling/20160211-longitudinal-genetic-modelling.pdf
- icon: github
  icon_pack: fab
  name: Code
  url: https://github.com/mcanouil/slides/tree/main/20160211-longitudinal-genetic-modelling

# url_code: ""
# url_pdf: ""
# url_slides: ""
# url_video: ""
---
