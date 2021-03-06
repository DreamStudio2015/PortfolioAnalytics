% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/constraints.R
\name{insert_constraints}
\alias{insert_constraints}
\title{Insert a list of constraints into the constraints slot of a portfolio object}
\usage{
insert_constraints(portfolio, constraints)
}
\arguments{
\item{portfolio}{object of class 'portfolio'}

\item{constraints}{list of constraint objects}
}
\description{
This is a helper function primarily for backwards compatibility to insert
constraints from a 'v1_constraint' object into the v2 'portfolio' object.
}
\author{
Ross Bennett
}
