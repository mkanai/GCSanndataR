#' @title GCSAnnData
#'
#' @description
#' Implementation of an AnnData object backed by a Google Cloud Storage h5ad file.
#' This class uses the Python package `gcs_anndata` to access h5ad files stored on GCS.
#'
#' @noRd
GCSAnnData <- R6::R6Class(
  "GCSAnnData", # nolint
  inherit = utils::getFromNamespace("AbstractAnnData", "anndataR"),
  cloneable = FALSE,
  private = list(
    .gcs_path = NULL,
    .py_object = NULL,

    # Helper function to check if the Python object is valid
    .check_valid = function() {
      if (is.null(private$.py_object)) {
        cli_abort("GCS AnnData object is not initialized or has been closed")
      }
    },

    # Helper function to raise error for write operations
    .read_only_error = function(field_name) {
      cli_abort("Cannot modify {.field {field_name}} in GCSAnnData. All fields are read-only.")
    },

    # Helper function to access Python object attributes with error handling
    .get_py_attr = function(attr_name, as_char = FALSE) {
      tryCatch(
        {
          result <- private$.py_object[[attr_name]]
          if (as_char) result <- as.character(result)
          return(result)
        },
        error = function(e) {
          cli_abort(paste0("Access to {.field ", attr_name, "} is not supported by gcs_anndata"))
        }
      )
    },

    # Helper function to convert indices to Python format (0-based)
    .convert_indices = function(idx) {
      if (is.numeric(idx)) {
        return(as.integer(idx) - 1L) # Convert to 0-based indexing for Python
      } else if (is.logical(idx)) {
        return(which(idx) - 1L) # Convert logical to integer indices
      }
      return(idx) # Return as is for other types (e.g., character)
    },

    # Helper function to ensure result is a matrix
    .ensure_matrix = function(result, is_column = TRUE) {
      if (!is.matrix(result)) {
        if (is_column) {
          # Convert to a matrix with one column
          result <- matrix(result, ncol = 1, dimnames = list(names(result), NULL))
        } else {
          # Convert to a matrix with one row
          result <- matrix(result, nrow = 1, dimnames = list(NULL, names(result)))
        }
      }
      return(result)
    }
  ),
  active = list(
    #' @field X The X slot. Only accepts indexed access [row_idx, col_idx], [row_idx, ] or [, col_idx].
    X = function(value) {
      private$.check_valid()
      if (missing(value)) {
        # Create an object with the GCSAnnDataXMatrix class
        result <- structure(
          list(),
          class = "GCSAnnDataXMatrix",
          parent = self # Store reference to parent object
        )
        return(result)
      } else {
        private$.read_only_error("X")
      }
    },

    #' @field layers The layers slot.
    layers = function(value) {
      private$.check_valid()
      if (missing(value)) {
        private$.get_py_attr("layers")
      } else {
        private$.read_only_error("layers")
      }
    },

    #' @field obs The obs slot
    obs = function(value) {
      private$.check_valid()
      if (missing(value)) {
        private$.get_py_attr("obs")
      } else {
        private$.read_only_error("obs")
      }
    },

    #' @field var The var slot
    var = function(value) {
      private$.check_valid()
      if (missing(value)) {
        private$.get_py_attr("var")
      } else {
        private$.read_only_error("var")
      }
    },

    #' @field obs_names Names of observations
    obs_names = function(value) {
      private$.check_valid()
      if (missing(value)) {
        private$.get_py_attr("obs_names", as_char = TRUE)
      } else {
        private$.read_only_error("obs_names")
      }
    },

    #' @field var_names Names of variables
    var_names = function(value) {
      private$.check_valid()
      if (missing(value)) {
        private$.get_py_attr("var_names", as_char = TRUE)
      } else {
        private$.read_only_error("var_names")
      }
    },

    #' @field obsm The obsm slot.
    obsm = function(value) {
      private$.check_valid()
      if (missing(value)) {
        private$.get_py_attr("obsm")
      } else {
        private$.read_only_error("obsm")
      }
    },

    #' @field varm The varm slot.
    varm = function(value) {
      private$.check_valid()
      if (missing(value)) {
        private$.get_py_attr("varm")
      } else {
        private$.read_only_error("varm")
      }
    },

    #' @field obsp The obsp slot.
    obsp = function(value) {
      private$.check_valid()
      if (missing(value)) {
        private$.get_py_attr("obsp")
      } else {
        private$.read_only_error("obsp")
      }
    },

    #' @field varp The varp slot.
    varp = function(value) {
      private$.check_valid()
      if (missing(value)) {
        private$.get_py_attr("varp")
      } else {
        private$.read_only_error("varp")
      }
    },

    #' @field uns The uns slot.
    uns = function(value) {
      private$.check_valid()
      if (missing(value)) {
        private$.get_py_attr("uns")
      } else {
        private$.read_only_error("uns")
      }
    },

    #' @field sparse_format The sparse format of the X matrix.
    sparse_format = function(value) {
      private$.check_valid()
      if (missing(value)) {
        private$.get_py_attr("sparse_format")
      } else {
        private$.read_only_error("sparse_format")
      }
    },

    #' @field obs_to_idx The observation name to index mapping
    obs_to_idx = function(value) {
      private$.check_valid()
      if (missing(value)) {
        private$.get_py_attr("obs_to_idx")
      } else {
        private$.read_only_error("obs_to_idx")
      }
    },

    #' @field var_to_idx The variable name to index mapping
    var_to_idx = function(value) {
      private$.check_valid()
      if (missing(value)) {
        private$.get_py_attr("var_to_idx")
      } else {
        private$.read_only_error("var_to_idx")
      }
    }
  ),
  public = list(
    #' @description Get rows from the X matrix by index
    #'
    #' @param i Row indices (numeric, logical, or character)
    #' @return A matrix with the selected rows
    get_rows = function(i) {
      private$.check_valid()

      # Convert indices to Python-compatible format
      i <- private$.convert_indices(i)

      # Get all columns for specified rows
      tryCatch(
        {
          result <- private$.py_object$get_rows(i)
          return(private$.ensure_matrix(result, is_column = FALSE))
        },
        error = function(e) {
          cli_abort(
            c(
              "Failed to access rows with the provided indices",
              "x" = e$message
            )
          )
        }
      )
    },

    #' @description Get columns from the X matrix by index
    #'
    #' @param j Column indices (numeric, logical, or character)
    #' @return A matrix with the selected columns
    get_columns = function(j) {
      private$.check_valid()

      # Convert indices to Python-compatible format
      j <- private$.convert_indices(j)

      # Get all rows for specified columns
      tryCatch(
        {
          result <- private$.py_object$get_columns(j)
          return(private$.ensure_matrix(result, is_column = TRUE))
        },
        error = function(e) {
          cli_abort(
            c(
              "Failed to access columns with the provided indices",
              "x" = e$message
            )
          )
        }
      )
    },

    #' @description GCSAnnData constructor
    #'
    #' @param gcs_path The GCS path to the h5ad file (e.g., "gs://bucket-name/path/to/file.h5ad")
    initialize = function(gcs_path) {
      # Store the GCS path
      private$.gcs_path <- gcs_path

      # Import the gcs_anndata Python package
      tryCatch(
        {
          gcs_anndata <- reticulate::import("gcs_anndata")
        },
        error = function(e) {
          cli_abort(
            c(
              "Failed to import Python package 'gcs_anndata'",
              "i" = "Make sure it's installed: pip install git+https://github.com/mkanai/gcs_anndata.git",
              "x" = e$message
            )
          )
        }
      )

      # Initialize the GCS AnnData object
      tryCatch(
        {
          private$.py_object <- gcs_anndata$GCSAnnData(gcs_path)
        },
        error = function(e) {
          cli_abort(
            c(
              "Failed to read h5ad file from GCS path: {.val {gcs_path}}",
              "x" = e$message
            )
          )
        }
      )
    },

    #' @description Close the GCS AnnData object
    close = function() {
      if (!is.null(private$.py_object)) {
        # Set to NULL to release the Python object
        private$.py_object <- NULL
      }
    },

    #' @description Number of observations in the AnnData object
    n_obs = function() {
      private$.check_valid()
      tryCatch(
        {
          private$.py_object$n_obs
        },
        error = function(e) {
          # Fallback to getting the length of obs_names
          length(self$obs_names)
        }
      )
    },

    #' @description Number of variables in the AnnData object
    n_vars = function() {
      private$.check_valid()
      tryCatch(
        {
          private$.py_object$n_vars
        },
        error = function(e) {
          # Fallback to getting the length of var_names
          length(self$var_names)
        }
      )
    },


    #' @description Print a summary of the GCSAnnData object
    print = function(...) {
      private$.check_valid()
      cat(
        "GCSAnnData object with n_obs \u00D7 n_vars = ",
        self$n_obs(),
        " \u00D7 ",
        self$n_vars(),
        "\n",
        sep = ""
      )
      cat("  GCS path: ", private$.gcs_path, "\n", sep = "")

      for (attribute in c(
        "obs",
        "var",
        "uns",
        "obsm",
        "varm",
        "layers",
        "obsp",
        "varp"
      )) {
        key_fun <- self[[paste0(attribute, "_keys")]]
        keys <-
          if (!is.null(key_fun)) {
            key_fun()
          } else {
            NULL
          }
        if (length(keys) > 0) {
          cat(
            "    ",
            attribute,
            ": ",
            paste(paste0("'", keys, "'"), collapse = ", "),
            "\n",
            sep = ""
          )
        }
      }
    }
  )
)

#' @export
# Define the S3 method for indexing GCSAnnDataXMatrix objects
`[.GCSAnnDataXMatrix` <- function(x, i, j, ..., drop = TRUE) {
  # Get the parent GCSAnnData object
  parent <- attr(x, "parent")

  # Handle row-only or column-only access
  if (missing(i)) {
    # Column-only access: get all rows for specified columns
    if (missing(j)) {
      cli_abort(
        c(
          "At least one of row or column indices must be provided for GCSAnnData$X",
          "i" = "Use {.code ad$X[, col_idx]} or {.code ad$X[row_idx, ]} or {.code ad$X[row_idx, col_idx]}"
        )
      )
    }

    # Use the get_columns method
    return(parent$get_columns(j))
  } else if (missing(j)) {
    # Row-only access: get all columns for specified rows
    # Use the get_rows method
    return(parent$get_rows(i))
  } else {
    # Both row and column indices provided
    tryCatch(
      {
        # Check the sparse format to determine the optimal access pattern
        sparse_format <- parent$sparse_format

        if (sparse_format == "csr") {
          # For CSR format, first get rows then filter columns
          result <- parent$get_rows(i)
          if (is.character(j)) {
            j <- parent$var_to_idx(j)
          }
          return(result[, j, drop = drop])
        } else {
          # For CSC format or other formats, first get columns then filter rows
          result <- parent$get_columns(j)
          if (is.character(i)) {
            i <- parent$obs_to_idx(i)
          }
          return(result[i, , drop = drop])
        }
      },
      error = function(e) {
        cli_abort(
          c(
            "Failed to access data with the provided indices",
            "x" = e$message
          )
        )
      }
    )
  }
}

#' @export
print.GCSAnnDataXMatrix <- function(x, ...) {
  cat("GCSAnnDataXMatrix object\n")
  cat("  Use indexing to access data: [row_idx, col_idx], [row_idx, ], or [, col_idx]\n")
  cat("  Examples:\n")
  cat("    - Get specific rows: object[1:5, ]\n")
  cat("    - Get specific columns: object[, 1:5]\n")
  cat("    - Get a subset: object[1:5, 1:5]\n")
  invisible(x)
}
