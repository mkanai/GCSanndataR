#' @keywords internal
#'
#' @description GCSanndataR provides Google Cloud Storage-backed AnnData (GCSAnnData)
#' functionality for R. It allows users to work with AnnData objects stored in Google
#' Cloud Storage without downloading the entire file. The GCSAnnData object
#' stores a data matrix `X` together with annotations of observations
#' `obs` (`obsm`, `obsp`) and variables `var` (`varm`, `varp`).
#' Additional layers of data can be stored in `layers` and unstructured
#' annotations in `uns`.
#'
#' @section Functions that can be used to create GCSAnnData objects:
#'
#'   * [read_h5ad()]: Read an AnnData file from Google Cloud Storage.
#'
#' @section A GCSAnnData object has the following slots:
#'
#' Access them by using the `$` operator. Example: `gcs_adata$obs`.
#'
#' * `X`: A matrix of observations by variables.
#' * `obs`: A data frame of observations.
#' * `var`: A data frame of variables.
#' * `obs_names`: Names of observations (alias for `rownames(obs)`).
#' * `var_names`: Names of variables (alias for `rownames(var)`).
#' * `layers`: A named list of matrices with the same dimensions as `X`.
#' * `obsm`: A named list of matrices with the same number of rows as `obs`.
#' * `varm`: A named list of matrices with the same number of rows as `var`.
#' * `obsp`: A named list of sparse matrices with the same number of rows and columns as the number of observations.
#' * `varp`: A named list of sparse matrices with the same number of rows and columns as the number of variables.
#' * `uns`: A named list of unstructured annotations.
#'
#' @section A GCSAnnData object has the following methods:
#'
#' Access them by using the `$` operator. Example: `gcs_adata$print()`.
#'
#' * `print()`: Print a summary of the GCSAnnData object.
#' * `shape()`: Dimensions (observations x variables) of the GCSAnnData object.
#' * `n_obs()`: Number of observations in the GCSAnnData object.
#' * `n_vars()`: Number of variables in the GCSAnnData object.
#' * `obs_keys()`: Column names of `obs`.
#' * `var_keys()`: Column names of `var`.
#' * `layers_keys()`: Element names of `layers`.
#' * `obsm_keys()`: Element names of `obsm`.
#' * `varm_keys()`: Element names of `varm`.
#' * `obsp_keys()`: Element names of `obsp`.
#' * `varp_keys()`: Element names of `varp`.
#' * `uns_keys()`: Element names of `uns`.
#'
#' @section Conversion methods:
#'
#' Access them by using the `$` operator. Example: `gcs_adata$to_Seurat()`.
#'
#' * `to_SingleCellExperiment()`: Convert to SingleCellExperiment.
#' * `to_Seurat()`: Convert to Seurat.
#'
"_PACKAGE"

## usethis namespace: start
#' @importFrom cli cli_abort cli_warn cli_inform
#' @importFrom purrr map_lgl map_dfr
#' @importFrom methods as new
## usethis namespace: end
NULL
