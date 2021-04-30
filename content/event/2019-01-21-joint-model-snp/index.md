---
title: Jointly Modelling SNPs with Survival & Longitudinal Trait
summary: | 
    Slides associated with the article 'Jointly Modelling Single Nucleotide Polymorphisms With Longitudinal and Time-to-Event Trait: An Application to Type 2 Diabetes and Fasting Plasma Glucose' (DOI:[10.3389/fgene.2018.00210](https://doi.org/10.3389/fgene.2018.00210)).
abstract: |
    In observational cohorts, longitudinal data are collected with repeated measurements at predetermined time points for many biomarkers, along with other variables measured at baseline. In these cohorts, time until a certain event of interest occurs is reported and very often, a relationship will be observed between some biomarker repeatedly measured over time and that event. Joint models were designed to efficiently estimate statistical parameters describing this relationship by combining a mixed model for the longitudinal biomarker trajectory and a survival model for the time until occurrence of the event, using a set of random effects to account for the relationship between the two types of data. In this paper, we discuss the implementation of joint models in genetic association studies. First, we check model consistency based on different simulation scenarios, by varying sample sizes, minor allele frequencies and number of repeated measurements. Second, using genotypes assayed with the Metabochip DNA arrays (Illumina) from about 4,500 individuals recruited in the French cohort D.E.S.I.R. (Data from an Epidemiological Study on the Insulin Resistance syndrome), we assess the feasibility of implementing the joint modelling approach in a real high-throughput genomic dataset. An alternative model approximating the joint model, called the Two-Step approach (TS), is also presented. Although the joint model shows more precise and less biased estimators than its alternative counterpart, the TS approach results in much reduced computational times, and could thus be used for testing millions of SNPs at the genome-wide scale.

all_day: false

date: "2019-01-21T14:00:00Z"
# date_end: "2019-01-21
publishDate: "2019-01-21"

event: |
    A Statistical Seminar Applied on Type 2 Diabetes (Host: Pr. Paul Franks)
# event_url: 
location: Lund University Diabetes Centre
address:
  # street: 450 Serra Mall
  city: Malmö
  postcode: '214 28'
  country: Sweden

featured: false
image:
  focal_point: Right

projects: []

tags:
  - joint modelling
  - survival analysis
  - longitudinal biomarker
  - genetics
  - type 2 diabetes
  - glycaemia
  - english
  - research

links:  
- icon: file-alt
  icon_pack: far
  name: Slides
  url: https://m.canouil.fr/slides/20190121-joint-model-snp/
- icon: github
  icon_pack: fab
  name: Code
  url: https://github.com/mcanouil/joint_model

# url_code: ""
# url_pdf: ""
# url_slides: ""
# url_video: ""
---



<div class="embed-responsive embed-responsive-16by9 xaringan">
  <iframe class="embed-responsive-item" src="https://m.canouil.fr/slides/20190121-joint-model-snp/" allowfullscreen></iframe>
</div>
