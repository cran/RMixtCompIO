# MixtComp version 4.0  - july 2019
# Copyright (C) Inria - Université de Lille - CNRS

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>


# Generate a functional observation using an interpolating polynomial instead of the generating model.
# This allows for a little more flexibility and convenience in specifying data than functionalGenerator
# which is currently bugged anyway.
#
# @param param A structure describing the points by which the interpolating polynomial is supposed to go through.
# @return The generated observation as a string.
# @examples
# param <- list(
#   x = c(0., 10., 20.),
#   y = c(0., 10., 0.),
#   sd = 0.1,
#   tMin = 0.,
#   tMax = 20.,
#   nTime = 100)
# functionalInterPolyGenerator(param)
# @author Vincent Kubicki
functionalInterPolyGenerator <- function(present, param) {
  timeObs <- vector("character", param$nTime)

  nCoeff <- length(param$x)
  v <- vandermonde(param$x, nCoeff)
  a <- solve(v, param$y)
  t <- vector(mode = "numeric", length = param$nTime)

  for (i in 1:param$nTime) {
    t[i] <- runif(1, param$tMin, param$tMax)
  }
  t <- sort(t)

  for (i in 1:param$nTime) {
    x <- evalFunc(a, t[i]) + rnorm(1, mean = 0, sd = param$sd)
    timeObs[i] <- paste(t[i], x, sep = ":")
  }

  xStr <- paste(timeObs, collapse = ",")

  return(xStr)
}

# @author Vincent Kubicki
vandermonde <- function(vec, nCoeff) {
  v <- matrix(nrow = nCoeff, ncol = nCoeff)
  for (i in 1:nCoeff) {
    for (j in 1:nCoeff) {
      v[i, j] <- vec[i]**(j - 1)
    }
  }

  return(v)
}

# @author Vincent Kubicki
evalFunc <- function(a, x) {
  nObs <- length(x)
  nCoeff <- length(a)
  y <- vector(mode = "numeric", length = length(x))

  for (i in 1:nObs) {
    y[i] <- 0.
    for (k in 1:nCoeff) {
      y[i] <- y[i] + a[k] * (x[i]**(k - 1))
    }
  }

  return(y)
}
