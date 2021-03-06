% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/drive_find.R
\name{drive_find}
\alias{drive_find}
\title{Find files on Google Drive}
\usage{
drive_find(pattern = NULL, trashed = FALSE, type = NULL,
  n_max = Inf, team_drive = NULL, corpus = NULL, ...,
  verbose = TRUE)
}
\arguments{
\item{pattern}{Character. If provided, only the items whose names match this
regular expression are returned. This is implemented locally on the results
returned by the API.}

\item{trashed}{Logical. Whether to search files that are not in the trash
(the default), only files that are in the trash (\code{trashed = TRUE}), or to
search regardless of trashed status (\code{trashed = NA}).}

\item{type}{Character. If provided, only files of this type will be returned.
Can be anything that \code{\link[=drive_mime_type]{drive_mime_type()}} knows how to handle. This is
processed by googledrive and sent as a query parameter.}

\item{n_max}{Integer. An upper bound on the number of items to return. This
applies to the results requested from the API, which may be further
filtered locally, via the \code{pattern} argument.}

\item{team_drive}{Anything that identifies one specific Team Drive: its name,
its id or URL marked with \code{\link[=as_id]{as_id()}}, or a \code{\link{dribble}}. Is pre-processed
with \code{\link[=as_team_drive]{as_team_drive()}}.  Read more about \link[=team_drives]{Team Drives}.}

\item{corpus}{Character, specifying the search collection. Only relevant in
the Team Drives context. If specified, must be one of \code{"user"}, \code{"all"}, or
\code{"domain"}. Read more about \link[=team_drives]{Team Drives}.}

\item{...}{Other parameters to pass along in the request. The most likely
candidate is \code{q}. See below and the API's
\href{https://developers.google.com/drive/v3/web/search-parameters}{Search for Files guide}.}

\item{verbose}{Logical, indicating whether to print informative messages
(default \code{TRUE}).}
}
\value{
An object of class \code{\link{dribble}}, a tibble with one row per item.
}
\description{
This is the closest googledrive function to what you can do at
\url{https://drive.google.com}: by default, you just get a listing of your files.
You can also search in various ways, e.g., filter by file type or ownership
or even work with \link[=team_drives]{Team Drive files}, if you have access. This
is a very powerful function. Together with the more specific \code{\link[=drive_get]{drive_get()}},
this is the main way to identify files to target for downstream work.

Note: \href{https://gsuite.google.com/learning-center/products/drive/get-started-team-drive/}{Team Drives}
are only available to users of certain enhanced Google services, such as G
Suite Enterprise, G Suite Business, or G Suite for Education.
}
\section{File type}{


The \code{type} argument is pre-processed with \code{\link[=drive_mime_type]{drive_mime_type()}}, so you can
use a few shortcuts and file extensions, in addition to full-blown MIME
types. googledrive forms a search clause to pass to \code{q}.
}

\section{Search parameters}{


Do advanced search on file properties by providing search clauses to the
\code{q} parameter that is passed to the API via \code{...}. Multiple \code{q} clauses or
vector-valued \code{q} are combined via 'and'.
}

\section{Trash}{


By default, \code{drive_find()} sets \code{trashed = FALSE} and does not include
files in the trash. Literally, it adds \code{q = "trashed = false"} to the
query. To search \emph{only} the trash, set \code{trashed = TRUE}. To see files
regardless of trash status, set \code{trashed = NA}, which adds
\code{q = "(trashed = true or trashed = false)"} to the query.
}

\section{Team Drives}{


If you have access to Team Drives, you'll know. Use \code{team_drive} or \code{corpus}
to search one or more Team Drives or a domain. See
\link[=team_drives]{Access Team Drives} for more.
}

\examples{
\dontrun{
## list "My Drive" w/o regard for folder hierarchy
drive_find()

## filter for folders, the easy way and the hard way
drive_find(type = "folder")
drive_find(q = "mimeType = 'application/vnd.google-apps.folder'")

## filter for Google Sheets, the easy way and the hard way
drive_find(type = "spreadsheet")
drive_find(q = "mimeType='application/vnd.google-apps.spreadsheet'")

## files whose names match a regex
drive_find(pattern = "jt")

## search for files located directly in your root folder
drive_find(q = "'root' in parents")
## FYI: this is equivalent to
drive_ls("~/")

## control page size or cap the number of files returned
drive_find(pageSize = 50)
## all params passed through `...` can be camelCase or snake_case
drive_find(page_size = 50)
drive_find(n_max = 58)
drive_find(page_size = 5, n_max = 15)

## various ways to specify q search clauses
## multiple q's
drive_find(q = "name contains 'TEST'",
           q = "modifiedTime > '2017-07-21T12:00:00'")
## vector q
drive_find(q = c("starred = true", "visibility = 'anyoneWithLink'"))

## default `trashed = FALSE` excludes files in the trash
## `trashed = TRUE` consults ONLY file in the trash
drive_find(trashed = TRUE)
## `trashed = NA` disregards trash status completely
drive_find(trashed = NA)
}

}
\seealso{
Wraps the \code{files.list} endpoint:
\itemize{
\item \url{https://developers.google.com/drive/v3/reference/files/list}
}

Helpful resource for forming your own queries:
\itemize{
\item \url{https://developers.google.com/drive/v3/web/search-parameters}
}
}
