---
# Documentation: https://wowchemy.com/docs/managing-content/

title: 'Jointly Modelling Single Nucleotide Polymorphisms with Longitudinal and Time-to-Event
  Trait: An Application to Type 2 Diabetes and Fasting Plasma Glucose'
subtitle: ''
summary: ''
authors:
- Mickaël Canouil
- Beverley Balkau
- Ronan Roussel
- Philippe Froguel
- Ghislain Rocheleau
tags:
- Longitudinal Studies
- Diabetes Mellitus
- Fasting plasma glucose
- Genetic association
- Joint modelling
- Mixed model
- survival analysis
- Type 2
categories: []
date: '2018-06-01'
lastmod: 2022-02-08T21:11:54+01:00
featured: false
draft: false

# Featured image
# To use, add an image named `featured.jpg/png` to your page's folder.
# Focal points: Smart, Center, TopLeft, Top, TopRight, Left, Right, BottomLeft, Bottom, BottomRight.
image:
  caption: ''
  focal_point: ''
  preview_only: false

# Projects (optional).
#   Associate this post with one or more of your projects.
#   Simply enter your project's folder or file name without extension.
#   E.g. `projects = ["internal-project"]` references `content/project/deep-learning/index.md`.
#   Otherwise, set `projects = []`.
projects: []
publishDate: '2022-02-08T20:11:54.380033Z'
publication_types:
- '2'
abstract: |
    In observational cohorts, longitudinal data are collected with repeated measurements at predetermined time points for many biomarkers, along with other variables measured at baseline. In these cohorts, time until a certain event of interest occurs is reported and very often, a relationship will be observed between some biomarker repeatedly measured over time and that event. Joint models were designed to efficiently estimate statistical parameters describing this relationship by combining a mixed model for the longitudinal biomarker trajectory and a survival model for the time until occurrence of the event, using a set of random effects to account for the relationship between the two types of data. In this paper, we discuss the implementation of joint models in genetic association studies. First, we check model consistency based on different simulation scenarios, by varying sample sizes, minor allele frequencies and number of repeated measurements. Second, using genotypes assayed with the Metabochip DNA arrays (Illumina) from about 4,500 individuals recruited in the French cohort D.E.S.I.R. (Data from an Epidemiological Study on the Insulin Resistance syndrome), we assess the feasibility of implementing the joint modelling approach in a real high-throughput genomic dataset. An alternative model approximating the joint model, called the Two-Step approach (TS), is also presented. Although the joint model shows more precise and less biased estimators than its alternative counterpart, the TS approach results in much reduced computational times, and could thus be used for testing millions of SNPs at the genome-wide scale.
publication: '*Frontiers in Genetics*'
doi: 10.3389/fgene.2018.00210
---
