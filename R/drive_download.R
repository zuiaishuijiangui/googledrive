#' Download a Drive file
#'
#' @description This function downloads a file from Google Drive. Native Google
#' file types, such as Google Docs, Google Sheets, and Google Slides, must be
#' exported to a conventional local file type. This can be specified:
#'   * explicitly via `type`
#'   * implicitly via the file extension of `path`
#'   * not at all, i.e. rely on default built into googledrive
#' @description To see what export file types are even possible, see the
#' [Drive API documentation](https://developers.google.com/drive/v3/web/manage-downloads#downloading_google_documents).
#' Returned dribble contains local path to downloaded file in `local_path`.
#'
#' @template file-singular
#' @param path Character. Path for output file. If absent, the default file name
#'   is the file's name on Google Drive and the default location is working
#'   directory, possibly with an added file extension.
#' @param type Character. Only consulted if `file` is a native Google file.
#'   Specifies the desired type of the downloaded file. Will be processed via
#'   [drive_mime_type()], so either a file extension like `"pdf"` or a full MIME
#'   type like `"application/pdf"` is acceptable.
#' @param overwrite A logical scalar. If `path` already exists, do you want to
#'   overwrite it?
#' @template verbose
#' @template dribble-return
#' @export
#' @examples
#' \dontrun{
#' ## Upload a csv file into a Google Sheet
#' file <- drive_upload(
#'   drive_example("chicken.csv"),
#'   type = "spreadsheet"
#'   )
#'
#' ## Download Sheet as csv, explicit type
#' (downloaded_file <- drive_download(file, type = "csv"))
#'
#' ## See local path to new file
#' downloaded_file$local_path
#'
#' ## Download as csv, type implicit in file extension
#' drive_download(file, path = "my_csv_file.csv")
#'
#' ## Download with default name and type (xlsx)
#' drive_download(file)
#'
#' ## Clean up
#' unlink(c("chicken.csv", "chicken.csv.xlsx", "my_csv_file.csv"))
#' drive_rm(file)
#' }
drive_download <- function(file,
                           path = NULL,
                           type = NULL,
                           overwrite = FALSE,
                           verbose = TRUE) {
  if (!is.null(path) && file.exists(path) && !overwrite) {
    stop_glue("\nPath exists and overwrite is FALSE:\n  * {path}")
  }
  file <- as_dribble(file)
  file <- confirm_single_file(file)

  ## preserve extension from path, before possible override by file$name
  ext <- file_ext_safe(path)
  path <- path %||% file$name

  mime_type <- file$drive_resource[[1]]$mimeType

  if (!grepl("google", mime_type) && !is.null(type)) {
    message("Ignoring `type`. Only consulted for native Google file types.")
  }

  if (grepl("google", mime_type)) {
    export_type <- type %||% ext %||% get_export_mime_type(mime_type)
    export_type <- drive_mime_type(export_type)
    verify_export_mime_type(mime_type, export_type)
    path <- apply_extension(path, drive_extension(export_type))

    request <- request_generate(
      endpoint = "drive.files.export",
      params = list(
        fileId = file$id,
        mimeType = export_type
      )
    )
  } else {
    request <- request_generate(
      endpoint = "drive.files.get",
      params = list(
        fileId = file$id,
        alt = "media"
      )
    )
  }

  response <- request_make(
    request,
    httr::write_disk(path, overwrite = overwrite)
  )
  success <- httr::status_code(response) == 200 && file.exists(path)

  if (success) {
    if (verbose) {
      message_glue(
        "\nFile downloaded:\n  * {file$name}\n",
        "Saved locally as:\n  * {path}"
      )
    }
  } else {
    stop_glue("The file doesn't seem to have downloaded.")
  }
  invisible(put_column(file, nm = "local_path", val = path, .after = "name"))
}

## get the default export MIME type for a native Google MIME type
## examples:
##    Google Doc --> MS Word
##  Google Sheet --> MS Excel
## Google Slides --> MS PowerPoint
get_export_mime_type <- function(mime_type) {
  m <- .drive$translate_mime_types$mime_type_google == mime_type &
    is_true(.drive$translate_mime_types$default)
  if (!any(m)) {
    stop_glue("\nNot a recognized Google MIME type:\n  * {mime_type}")
  }
  .drive$translate_mime_types$mime_type_local[m]
}

## affirm that export_type is a valid export MIME type for a native Google file
## of type mime_type
verify_export_mime_type <- function(mime_type, export_type) {
  m <- .drive$translate_mime_types$mime_type_google == mime_type
  ok <- export_type %in% .drive$translate_mime_types$mime_type_local[m]
  if (!ok) {
    ## to be really nice, we would look these up in drive_mime_type() tibble
    ## and use the human_type, if found
    stop_glue(
      "\nCannot export Google file of type:\n  * {mime_type}\n",
      "as a file of type:\n  * {export_type}"
    )
  }
  export_type
}
