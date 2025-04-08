# GCSanndataR

## Overview

GCSanndataR is an R package that extends [anndataR](https://github.com/scverse/anndataR) to provide Google Cloud Storage-backed AnnData functionality. This package allows users to work with AnnData objects stored in Google Cloud Storage without downloading the entire file, enabling efficient access to large single-cell datasets directly from the cloud.

## Installation

```r
# Install from GitHub
remotes::install_github("mkanai/GCSanndataR")
GCSanndataR::install_gcs_anndata()
```

## Usage

### Reading AnnData from Google Cloud Storage

```r
library(GCSanndataR)

# Read an AnnData file from Google Cloud Storage
# This will automatically use GCSAnnData backend
gcs_adata <- read_h5ad("gs://my-bucket/my-file.h5ad")

# Access specific rows and columns
gcs_adata$X[1:10, 1:5]

# Access using names
gcs_adata$X[c("cell1", "cell2"), c("gene1", "gene2")]
```

## Features

- Direct access to AnnData objects stored in Google Cloud Storage
- Lazy loading of data - only loads the parts of the file that are needed
- Compatible with the anndataR API

## Requirements

- R >= 4.0.0
- anndataR
- reticulate >= 1.36.1
- Google Cloud Storage access configured

## License

MIT
