---
title: |
    NACHO: NAnostring quality Control dasHbOard
summary: | 
    Slides associated with the article 'NACHO: an R package for quality control of NanoString nCounter data.' (DOI:[10.1093/bioinformatics/btz647](https://doi.org/10.1093/bioinformatics/btz647)).
abstract: |
    The NanoString<sup>TM</sup> nCounter® is a platform for the targeted quantification of expression data in biofluids and tissues. While software by the manufacturer is available in addition to third parties packages, they do not provide a complete quality control (QC) pipeline. Here, we present NACHO ('NAnostring quality Control dasHbOard'), a comprehensive QC R-package. The package consists of three subsequent steps: summarize, visualize and normalize. The summarize function collects all the relevant data and stores it in a tidy format, the visualize function initiates a dashboard with plots of the relevant QC outcomes. It contains QC metrics that are measured by default by the manufacturer, but also calculates other insightful measures, including the scaling factors that are needed in the normalization step. In this normalization step, different normalization methods can be chosen to optimally preprocess data. Together, NACHO is a comprehensive method that optimizes insight and preprocessing of nCounter® data.

all_day: true

date: "2019-09-06"
# date_end: "2019-09-06
publishDate: "2019-09-06"

event: Research Seminar
# event_url: ""
location: "Lausanne, Switzerland"
# address:
#   # street: 450 Serra Mall
#   city: Lausanne
#   postcode: '1000'
#   country: Switzerland

featured: false
image:
  focal_point: Right

projects: []

tags:
  - quality control
  - NanoString nCounter
  - gene expression
  - R
  - shiny
  - dashboard
  - normalisation

links:  
- icon: file-alt
  icon_pack: far
  name: Slides
  url: https://m.canouil.fr/slides/20190906-nacho/
- icon: github
  icon_pack: fab
  name: Code
  url: https://github.com/mcanouil/NACHO_slides
  
# url_code: ""
# url_pdf: ""
# url_slides: ""
# url_video: ""
---



<div class="embed-responsive embed-responsive-16by9 xaringan">
  <iframe class="embed-responsive-item" src="https://m.canouil.fr/slides/20190906-nacho/" allowfullscreen></iframe>
</div>