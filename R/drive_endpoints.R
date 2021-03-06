#' List Drive endpoints
#'
#' Returns a list of selected Drive API v3 endpoints, as stored inside the
#' googledrive package. The names of this list (or the `id` sub-elements) are
#' the nicknames that can be used to specify an endpoint in
#' [request_generate()]. For each endpoint, we store its nickname or `id`, the
#' associated HTTP verb, the `path`, and details about the parameters. This list
#' is derived programmatically from the
#' [Drive API v3 Discovery Document](https://www.googleapis.com/discovery/v1/apis/drive/v3/rest).
#'
#' @param i The name(s) or integer index(ices) of the endpoints to return.
#'   Optional. By default, the entire list is returned.
#'
#' @return A list containing some or all of the subset of the Drive API v3
#'   endpoints that are used internally by googledrive.
#' @export
#'
#' @examples
#' str(drive_endpoints(), max.level = 2)
#' drive_endpoints("drive.files.delete")
#' drive_endpoints(4)
drive_endpoints <- function(i = NULL) {
  if (is.null(i) || is_expose(i)) {
    i <- seq_along(.endpoints)
  }
  .endpoints[i]
}
