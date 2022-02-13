---
# Documentation: https://wowchemy.com/docs/managing-content/

title: 'NACHO: An R package for Quality Control of NanoString nCounter Data'
subtitle: ''
summary: ''
authors:
- Mickaël Canouil
- Gerard A Bouland
- Amélie Bonnefond
- Philippe Froguel
- Leen M 't Hart
- Roderick C Slieker
tags: []
categories: []
date: '2019-08-01'
lastmod: 2022-02-08T21:11:52+01:00
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
publishDate: '2022-02-08T20:11:52.295860Z'
publication_types:
- '2'
abstract: |
  The NanoString&trade; nCounter&reg; is a platform for the targeted quantification of expression data in biofluids and tissues. While software by the manufacturer is available in addition to third parties packages, they do not provide a complete quality control (QC) pipeline. Here, we present NACHO ('NAnostring quality Control dasHbOard'), a comprehensive QC R-package. The package consists of three subsequent steps: summarize, visualize and normalize. The summarize function collects all the relevant data and stores it in a tidy format, the visualize function initiates a dashboard with plots of the relevant QC outcomes. It contains QC metrics that are measured by default by the manufacturer, but also calculates other insightful measures, including the scaling factors that are needed in the normalization step. In this normalization step, different normalization methods can be chosen to optimally preprocess data. Together, NACHO is a comprehensive method that optimizes insight and preprocessing of nCounter&reg; data.
publication: '*Bioinformatics*'
doi: 10.1093/bioinformatics/btz647
---
