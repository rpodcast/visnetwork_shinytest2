## Intro

This repository contains a minimal [Shiny](https://shiny.posit.co) application that leverages an HTML widget [`{visNetwork}`](https://github.com/datastorm-open/visNetwork) containing built-in (and customized) interactions in JavaScript.

## Setup

This application was created using R version `4.2.2` and package dependencies managed with [`{renv}`](https://rstudio.github.io/renv/index.html). To run this application on your system, follow these directions:

1. Clone the repository to your local file system
1. Either open the `visnetwork_shinytest2.Rproj` file in RStudio, or launch R in the local directory where you cloned the repository.
1. Restore the package environment by running `renv::restore()` in the R console.
