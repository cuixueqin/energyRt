% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/getData.R
\name{getData}
\alias{getData}
\title{Extraxts data from scenario object}
\usage{
getData(..., parameter = NULL, variable = NULL, get.parameter = NULL,
  get.variable = NULL, merge = FALSE, zero.rm = TRUE, drop = TRUE,
  table = TRUE, use.dplyr = FALSE, stringsAsFactors = TRUE,
  yearsAsFactors = FALSE, name = NULL, ignore.case = FALSE,
  fixed = FALSE, useBytes = FALSE, invert = FALSE)
}
\arguments{
\item{parameter}{character vector with names of the model parameters}

\item{variable}{character vector with names of the model variables}

\item{get.parameter}{logical, if TRUE then search in interpolated parameters, and return if available}

\item{get.variable}{logical, if TRUE then search in variables, and return if available}

\item{drop}{# add 'drop.zero.dim = drop' and 'remove_zero_dim = drop'}

\item{tech}{character vector with names of tachnology objects}

\item{dem}{character vector with names of demand objects}

\item{sup}{character vector with names of sypply objects}

\item{comm}{character vector with names of commodity objects}

\item{group}{character vector group names in technology objects}

\item{region}{character vector with names of regions}

\item{year}{character or integer vector with years}

\item{slice}{character vector with names of slices}

\item{stg}{qqq}

\item{expp}{character vector with names of export processes}

\item{imp}{character vector with names of import processes}

\item{trade}{character vector with names of trade objects}

\item{remove_zero_dim}{rename to 'zero.rm'}
}
\description{
obj objects of class scenario, model, or list with object of the two classes
}
\details{
\code{...} filters for searching data in the objects, which include:
}
