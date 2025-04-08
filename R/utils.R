#' Install the gcs_anndata Python package
#'
#' This function installs the gcs_anndata Python package using reticulate.
#' The gcs_anndata package allows for reading AnnData objects directly from
#' Google Cloud Storage.
#'
#' @param ... Additional arguments passed to reticulate::py_install()
#'
#' @return Invisible NULL, called for side effect of installing the package
#'
#' @examples
#' \dontrun{
#' install_gcs_anndata()
#' }
#'
#' @seealso \code{\link[reticulate]{py_install}} for more details on installation options
#'
#' @export
install_gcs_anndata <- function(...) {
  reticulate::py_install("gcs_anndata", ...)
  invisible(NULL)
}
