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


# @author Vincent Kubicki
functionalInterPolyParam <- function(name) {
  Functional <- list(
    name = name,
    type = "Func_CS",
    generator = functionalInterPolyGenerator,
    paramStr = "nSub: 2, nCoeff: 2",
    param = list()
  )

  Functional$param[[1]] <- list(
    x = c(0., 10., 20.),
    y = c(0., 10., 0.),
    sd = 0.1,
    tMin = 0.,
    tMax = 20.,
    nTime = 100
  )

  Functional$param[[2]] <- list(
    x = c(0., 10., 20.),
    y = c(10., 0., 10.),
    sd = 0.1,
    tMin = 0.,
    tMax = 20.,
    nTime = 100
  )

  return(Functional)
}

# @author Vincent Kubicki
functionalParam1sub <- function(name) {
  Functional <- list()
  Functional$param <- list()
  Functional$param[[1]] <- list()
  Functional$param[[2]] <- list()

  Functional$name <- name
  Functional$type <- "Func_CS"
  Functional$generator <- functionalGenerator
  Functional$paramStr <- "nSub: 1, nCoeff: 2"

  coeffAlpha1 <- getLinEq(c(0., 100.), c(25., 0.)) # first sub

  coeffBeta11 <- getLinEq(c(0., 10.), c(50., 10.)) # first class, first sub

  coeffBeta21 <- getLinEq(c(0., 0.), c(50., 0.)) # second class, first sub

  alpha <- matrix(c(coeffAlpha1[1], coeffAlpha1[2]),
    1, 2,
    byrow = TRUE
  )

  beta1 <- matrix(c(coeffBeta11[1], coeffBeta11[2]),
    1, 2,
    byrow = TRUE
  )

  beta2 <- matrix(c(coeffBeta21[1], coeffBeta21[2]),
    1, 2,
    byrow = TRUE
  )

  sigma <- 0.01

  Functional$param[[1]]$alpha <- alpha
  Functional$param[[1]]$beta <- beta1
  Functional$param[[1]]$sigma <- c(sigma, sigma)
  Functional$param[[1]]$nTime <- 20
  Functional$param[[1]]$tMin <- 0.
  Functional$param[[1]]$tMax <- 50.

  Functional$param[[2]]$alpha <- alpha
  Functional$param[[2]]$beta <- beta2
  Functional$param[[2]]$sigma <- c(sigma, sigma)
  Functional$param[[2]]$nTime <- 20
  Functional$param[[2]]$tMin <- 0.
  Functional$param[[2]]$tMax <- 50.

  return(Functional)
}

# @author Vincent Kubicki
functionalParam2sub <- function(name) {
  Functional <- list()
  Functional$param <- list()
  Functional$param[[1]] <- list()
  Functional$param[[2]] <- list()

  Functional$name <- name
  Functional$type <- "Func_CS"
  Functional$generator <- functionalGenerator
  Functional$paramStr <- "nSub: 2, nCoeff: 2"

  coeffAlpha1 <- getLinEq(c(0., 100.), c(25., 0.)) # first sub
  coeffAlpha2 <- getLinEq(c(0., -100.), c(25., 0.)) # second sub

  coeffBeta11 <- getLinEq(c(0., 0.), c(25., 10.)) # first class, first sub
  coeffBeta12 <- getLinEq(c(25., 10.), c(50., 0.)) # first class, second sub

  coeffBeta21 <- getLinEq(c(0., 10.), c(25., 0.)) # second class, first sub
  coeffBeta22 <- getLinEq(c(25., 0.), c(50., 10.)) # second class, second sub

  alpha <- matrix(c(
    coeffAlpha1[1], coeffAlpha1[2],
    coeffAlpha2[1], coeffAlpha2[2]
  ),
  2, 2,
  byrow = TRUE
  )

  beta1 <- matrix(c(
    coeffBeta11[1], coeffBeta11[2],
    coeffBeta12[1], coeffBeta12[2]
  ),
  2, 2,
  byrow = TRUE
  )

  beta2 <- matrix(c(
    coeffBeta21[1], coeffBeta21[2],
    coeffBeta22[1], coeffBeta22[2]
  ),
  2, 2,
  byrow = TRUE
  )

  sigma <- 0.01


  Functional$param[[1]]$alpha <- alpha
  Functional$param[[1]]$beta <- beta1
  Functional$param[[1]]$sigma <- c(sigma, sigma)
  Functional$param[[1]]$nTime <- 20
  Functional$param[[1]]$tMin <- 0.
  Functional$param[[1]]$tMax <- 50.

  Functional$param[[2]]$alpha <- alpha
  Functional$param[[2]]$beta <- beta2
  Functional$param[[2]]$sigma <- c(sigma, sigma)
  Functional$param[[2]]$nTime <- 20
  Functional$param[[2]]$tMin <- 0.
  Functional$param[[2]]$tMax <- 50.

  return(Functional)
}

# @author Vincent Kubicki
getLinEq <- function(pointA, pointB) {
  a <- matrix(c(
    1., pointA[1],
    1., pointB[1]
  ),
  2, 2,
  byrow = TRUE
  )
  b <- c(pointA[2], pointB[2])
  x <- solve(a, b)

  return(x)
}
