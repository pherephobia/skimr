% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/skim.R
\name{skim}
\alias{skim}
\alias{skim_tee}
\alias{skim_without_charts}
\title{Skim a data frame, getting useful summary statistics}
\usage{
skim(data, ...)

skim_tee(data, ..., skim_fun = skim)

skim_without_charts(data, ...)
}
\arguments{
\item{data}{A tibble, or an object that can be coerced into a tibble.}

\item{...}{Columns to select for skimming. When none are provided, the
default is to skim all columns.}

\item{skim_fun}{The skim function used.}

\item{skim}{The skimming function to use in \code{skim_tee()}.}
}
\value{
A \code{skim_df} object, which also inherits the class(es) of the input
data. In many ways, the object behaves like a \code{\link[tibble:tibble]{tibble::tibble()}}.
}
\description{
\code{skim()} is an alternative to \code{\link[=summary]{summary()}}, quickly providing a broad
overview of a data frame. It handles data of all types, dispatching a
different set of summary functions based on the types of columns in the data
frame.
}
\details{
Each call produces a \code{skim_df}, which is a fundamentally a tibble with a
special print method. One unusual feature of this data frame is pseudo-
namespace for columns. \code{skim()} computes statistics by data type, and it
stores them in the data frame as \verb{<type>.<statistic>}. These types are
stripped when printing the results. The "base" skimmers (\code{n_missing} and
\code{complete_rate}) are the only columns that don't follow this behavior.
See \code{\link[=skim_with]{skim_with()}} for more details on customizing \code{skim()} and
\code{\link[=get_default_skimmers]{get_default_skimmers()}} for a list of default functions.

If you just want to see the printed output, call \code{skim_tee()} instead.
This function returns the original data. \code{skim_tee()} uses the default
\code{skim()}, but you can replace it with the \code{skim} argument.

The data frame produced by \code{skim} is wide and sparse. To avoid type coercion
\code{skimr} uses a type namespace for all summary statistics. Columns for numeric
summary statistics all begin \code{numeric}; for factor summary statistics
begin \code{factor}; and so on.

See \code{\link[=partition]{partition()}} and \code{\link[=yank]{yank()}} for methods for transforming this wide data
frame. The first function splits it into a list, with each entry
corresponding to a data type. The latter pulls a single subtable for a
particular type from the \code{skim_df}.

\code{skim()} is designed to operate in pipes and to generally play nicely with
other \code{tidyverse} functions. This means that you can use \code{tidyselect} helpers
within \code{skim} to select or drop specific columns for summary. You can also
further work with a \code{skim_df} using \code{dplyr} functions in a pipeline.
}
\section{Customizing skim}{

\code{skim()} is an intentionally simple function, with minimal arguments like
\code{\link[=summary]{summary()}}. Nonetheless, this package provides two broad approaches to
how you can customize \code{skim()}'s behavior. You can customize the functions
that are called to produce summary statistics with \code{\link[=skim_with]{skim_with()}}.
}

\section{Unicode rendering}{

If the rendered examples show unencoded values such as \verb{<U+2587>} you will
need to change your locale to allow proper rendering. Please review the
\emph{Using Skimr} vignette for more information
(\code{vignette("Using_skimr", package = "skimr")}).

Otherwise, we export \code{skim_without_charts()} to produce summaries without the
spark graphs. These are the source of the unicode dependency.
}

\examples{
skim(iris)

# Use tidyselect
skim(iris, Species)
skim(iris, starts_with("Sepal"))
skim(iris, where(is.numeric))

# Skim also works groupwise
iris \%>\%
  dplyr::group_by(Species) \%>\%
  skim()

# Which five numeric columns have the greatest mean value?
# Look in the `numeric.mean` column.
iris \%>\%
  skim() \%>\%
  dplyr::select(numeric.mean) \%>\%
  dplyr::top_n(5)

# Which of my columns have missing values? Use the base skimmer n_missing.
iris \%>\%
  skim() \%>\%
  dplyr::filter(n_missing > 0)

# Use skim_tee to view the skim results and
# continue using the original data.
chickwts \%>\%
  skim_tee() \%>\%
  dplyr::filter(feed == "sunflower")

# Produce a summary without spark graphs
iris \%>\%
  skim_without_charts()
}
