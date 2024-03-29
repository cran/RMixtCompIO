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

# define global variable i to avoid notes, used by the foreach loop
globalVariables("i")

#' @title Learn and predict a Mixture Model
#'
#' @description Estimate the parameter of a mixture model or predict the cluster of new samples.
#' It manages heterogeneous data as well as missing and incomplete data.
#'
#' @param algo a list containing the parameters of the SEM-Gibbs algorithm (see \emph{Details}).
#' @param data a data.frame, a matrix or a named list containing the data (see \emph{Details} \emph{Data format} sections).
#' @param resLearn output of \emph{rmcMultiRun} (only for predict mode).
#' @param model a named list containing models and hyperparameters (see \emph{Details} section).
#' @param nRun number of runs for every given number of class. If >1, SEM is run \code{nRun} times for every number of class,
#' and the best according to observed likelihood is kept.
#' @param nCore number of cores used for the parallelization of the \emph{nRun} runs.
#' @param verbose if TRUE, print some information.
#'
#' @return An object of class MixtComp

#' @details
#' The \emph{data} object is a list where each element corresponds to a variable, each element must be named.
#' Missing and incomplete data are managed, see section \emph{Data format} for how to format them.
#'
#' The \emph{model} object is a named list containing the variables to use in the model.
#' All variables listed in the \emph{model} object must be in the \emph{data} object.
#' \emph{model} can contain less variables than \emph{data}.
#' An element of the list corresponds to a model which is described by a list of 2 elements:
#' type containing the model name and paramStr containing the hyperparameters.
#' For example:
#' \code{model <- list(real1 = list(type = "Gaussian", paramStr = ""), func1 = list(type = "Func_CS", paramStr = "nSub: 4, nCoeff: 2"))}.
#'
#' Eight models are available in RMixtComp: \emph{Gaussian}, \emph{Multinomial}, \emph{Poisson}, \emph{NegativeBinomial},
#' \emph{Weibull}, \emph{Func_CS}, \emph{Func_SharedAlpha_CS}, \emph{Rank_ISR}.
#' \emph{Func_CS} and \emph{Func_SharedAlpha_CS} models require hyperparameters: the number of subregressions of functional
#' and the number of coefficients of each subregression.
#' These hyperparameters are specified by: \emph{nSub: i, nCoeff: k} in the \emph{paramStr} field of the \emph{model} object.
#' The \emph{Func_SharedAlpha_CS} is a variant of the \emph{Func_CS} model with the alpha parameter shared between clusters.
#' It means that the start and end of each subregression will be the same across the clusters.
#'
#'
#' To perform a (semi-)supervised clustering, user can add a variable named \emph{z_class} in the data and model objects
#' with \emph{LatentClass} as model in the model object.
#'
#'
#' The \emph{algo} object is a list containing the different number of iterations for the algorithm.
#' The algorithm is decomposed in a burn-in phase and a normal phase.
#' Estimates from the burn-in phase are not shown in output.
#' \itemize{
#'   \item{nClass: number of class}
#'   \item{nInd: number of individuals}
#'   \item{nbBurnInIter: Number of iterations of the burn-in part of the SEM algorithm.}
#'   \item{nbIter: Number of iterations of the SEM algorithm.}
#'   \item{nbGibbsBurnInIter: Number of iterations of the burn-in part of the Gibbs algorithm.}
#'   \item{nbGibbsIter: Number of iterations of the Gibbs algorithm.}
#'   \item{nInitPerClass: Number of individuals used to initialize each cluster (default = 10).}
#'   \item{nSemTry: Number of try of the algorithm for avoiding an error.}
#'   \item{confidenceLevel: confidence level for confidence bounds for parameter estimation}
#'   \item{ratioStableCriterion: stability partition required to stop earlier the SEM }
#'   \item{nStableCriterion: number of iterations of partition stability to stop earlier the SEM}
#' }
#'
#'
#' @section Data format:
#' - Gaussian data:
#' Gaussian data are real values with the dot as decimal separator.
#' Missing data are indicated by a \emph{?}. Partial data can be provided through intervals denoted by
#' \emph{[a:b]} where \emph{a} (resp. \emph{b}) is a real or \emph{-inf} (resp. \emph{+inf}).
#'
#'
#' - Categorical Data:
#' Categorical data must be consecutive integer with 1 as minimal value. Missing data are indicated by a \emph{?}.
#' For partial data, a list of possible values can be provided by \emph{{a_1,\dots,a_j}},
#' where \emph{a_i} denotes a categorical value.
#'
#' - Poisson and NegativeBinomial Data:
#' Poisson and NegativeBinomial data must be positive integer. Missing data are indicated by a \emph{?}.
#' Partial data can be provided through intervals denoted by
#' \emph{[a:b]} where \emph{a} and \emph{b} are  positive integers. \emph{b} can be \emph{+inf}.
#'
#' - Weibull Data:
#' Weibull data are real positive values with the dot as decimal separator.
#' Missing data are indicated by a \emph{?}. Partial data can be provided through intervals denoted by
#' \emph{[a:b]} where \emph{a} and \emph{b} are  positive reals. \emph{b} can be \emph{+inf}.
#'
#'
#' - Rank data:
#' The format of a rank is: \emph{o_1, \dots, o_j} where o_1 is an integer corresponding to the number of the object ranked
#' in 1st position.
#' For example: 4,2,1,3 means that the fourth object is ranked first then the second object is in second position and so on.
#' Missing data can be specified by replacing and object by a \emph{?} or a list of potential object, for example:
#' \emph{4, \{2 3\}, \{2 1\}, ?} means that the object ranked in second position is either the object number 2 or
#' the object number 3, then the object ranked in third position is either the object 2 or 1 and the last one can be anything.
#' A totally missing rank is specified by \emph{?,?,\dots,?}
#'
#' - Functional data:
#' The format of a functional data is: \emph{time_1:value_1,\dots, time_j:value_j}. Between individuals,
#' functional data can have different length and different time.
#' \emph{i} is the number of subregressions in a functional data and \emph{k} the number of coefficients
#'  of each regression (2 = linear, 3 = quadratic, ...). Missing data are not supported.
#'
#' - z_class:
#' To perform a (semi-)supervised clustering, user can add a variable named `z_class` (with eventually some missing values)
#' with "LatentClass" as model. Missing data are indicated by a \emph{?}. For partial data, a list of possible values
#' can be provided by \emph{{a_1,\dots,a_j}}, where \emph{a_i} denotes a class number.
#'
#' @section MixtComp object:
#' A MixtComp object is a result of a single run of MixtComp algorithm. It is a list containing three elements
#' \emph{mixture}, \emph{variable} and \emph{algo}.
#' If MixtComp fails to run, the list contains a single element: warnLog containing error messages.
#'
#' The \emph{mixture} element contains
#' \itemize{
#'   \item{BIC: value of BIC}
#'   \item{ICL: value of ICL}
#'   \item{nbFreeParameters: number of free parameters of the mixture}
#'   \item{lnObservedLikelihood: observed loglikelihood}
#'   \item{lnCompletedLikelihood: completed loglikelihood}
#'   \item{IDClass: entropy used to compute the discriminative power of variable:
#' -\eqn{\sum_{i=1}^n t_{ikj} log(t_{ikj})/(n * log(K))}}
#'   \item{IDClassBar: entropy used to compute the discriminative power of variable:
#' -\eqn{\sum_{i=1}^n (1-t_{ikj}) log((1-t_{ikj}))/(n * log(K))}}
#'   \item{delta: similarities between variables}
#'   \item{completedProbabilityLogBurnIn: evolution of the completed log-probability during the burn-in period
#' (can be used to check the convergence and determine the ideal number of iteration)}
#'   \item{completedProbabilityLogRun: evolution of the completed log-probability  after the burn-in period
#' (can be used to check the convergence and determine the ideal number of iteration)}
#'   \item{runTime: list containing the total execution time in seconds and the execution time of some subpart.}
#'   \item{lnProbaGivenClass: log-proportion + log-probability of x_i for each class}
#' }
#'
#'
#' The \emph{algo} list contains a copy of \emph{algo} parameter with extra elements:
#' nInd, nClass, mode ("learn" or "predict").
#'
#'
#' The \emph{variable} list contains 3 lists : \emph{data}, \emph{type} and \emph{param}.
#' Each of these lists contains a list for each variable (the name of each list is the name of the variable) and for
#' the class of samples (\emph{z_class}).
#' The \emph{type} list contains the model used for each variable.
#'
#' Each list of the \emph{data} list contains the completed data in the \emph{completed} element and
#' some statistics about them (\emph{stat}).
#'
#' The estimated parameter can be found in the \emph{stat} element in the \emph{param} list
#' (see Section \emph{View of an output object}).
#' For more details about the parameters of each model, you can refer to \link{rnorm}, \link{rpois}, \link{rweibull},
#' \link{rnbinom}, \link{rmultinom}, or references in the \emph{References} section.
#'
#'
#'
#'
#' @section View of a MixtComp object:
#' Example of output object with variables named "categorical", "gaussian", "rank", "functional", "poisson", "nBinom"
#' and "weibull" with respectively \emph{Multinomial}, \emph{Gaussian}, \emph{Rank_ISR}, \emph{Func_CS}
#' (or \emph{Func_SharedAlpha_CS}), \emph{Poisson}, \emph{NegativeBinomial} and \emph{Weibull} as model.
#'
#' \tabular{lll}{
#' output  \cr
#' |_______ \tab algo \tab __ nbBurnInIter\cr
#' |        \tab      \tab |_ nbIter\cr
#' |        \tab      \tab |_ nbGibbsBurnInIter\cr
#' |        \tab      \tab |_ nbGibbsIter\cr
#' |        \tab      \tab |_ nInitPerClass\cr
#' |        \tab      \tab |_ nSemTry\cr
#' |        \tab      \tab |_ ratioStableCriterion\cr
#' |        \tab      \tab |_ nStableCriterion\cr
#' |        \tab      \tab |_ confidenceLevel  \cr
#' |        \tab      \tab |_ mode \cr
#' |        \tab      \tab |_ nInd  \cr
#' |        \tab      \tab |_ nClass \cr
#' | \cr
#' |_______ \tab mixture \tab __ BIC \cr
#' |        \tab         \tab |_ ICL\cr
#' |        \tab         \tab |_ lnCompletedLikelihood\cr
#' |        \tab         \tab |_ lnObservedLikelihood \cr
#' |        \tab         \tab |_ IDClass  \cr
#' |        \tab         \tab |_ IDClassBar  \cr
#' |        \tab         \tab |_ delta  \cr
#' |        \tab         \tab |_ runTime \cr
#' |        \tab         \tab |_ nbFreeParameters \cr
#' |        \tab         \tab |_ completedProbabilityLogBurnIn \cr
#' |        \tab         \tab |_ completedProbabilityLogRun \cr
#' |        \tab         \tab |_ lnProbaGivenClass \cr
#' }
#' \tabular{llllll}{
#' |  \cr
#' |_______ \tab variable \tab __ type \tab __ z_class  \cr
#'          \tab          \tab |       \tab |_ categorical \cr
#'          \tab          \tab |       \tab |_ gaussian \cr
#'          \tab          \tab |       \tab |_ ...   \cr
#'          \tab          \tab |       \tab \cr
#'          \tab          \tab |_ data \tab __ z_class \tab __ completed\cr
#'          \tab          \tab |       \tab |          \tab |_ stat \cr
#'          \tab          \tab |       \tab |_ categorical \tab __ completed\cr
#'          \tab          \tab |       \tab |              \tab |_ stat \cr
#'          \tab          \tab |       \tab |_ ...         \tab \cr
#'          \tab          \tab |       \tab |_ functional \tab __ data\cr
#'          \tab          \tab |       \tab               \tab |_ time \cr
#'          \tab          \tab |       \tab \cr
#'          \tab          \tab |_ param \tab __ z_class \tab __ stat\cr
#'          \tab          \tab          \tab |          \tab |_ log \cr
#'          \tab          \tab          \tab |          \tab |_ paramStr \cr
#'          \tab          \tab          \tab |_ functional \tab __ alpha \tab __ stat\cr
#'          \tab          \tab          \tab |             \tab |        \tab |_ log \cr
#'          \tab          \tab          \tab |             \tab |_ beta  \tab __ stat\cr
#'          \tab          \tab          \tab |             \tab |        \tab |_ log \cr
#'          \tab          \tab          \tab |             \tab |_ sd    \tab __ stat\cr
#'          \tab          \tab          \tab |             \tab |        \tab |_ log \cr
#'          \tab          \tab          \tab |             \tab |_ paramStr \cr
#'          \tab          \tab          \tab |_ rank \tab __ mu \tab __ stat\cr
#'          \tab          \tab          \tab |       \tab |     \tab |_ log \cr
#'          \tab          \tab          \tab |       \tab |_ pi \tab __ stat\cr
#'          \tab          \tab          \tab |       \tab |     \tab |_ log \cr
#'          \tab          \tab          \tab |       \tab |_ paramStr \cr
#'          \tab          \tab          \tab |       \tab       \tab \cr
#'          \tab          \tab          \tab |_ gaussian \tab __ stat\cr
#'          \tab          \tab          \tab |           \tab |_ log \cr
#'          \tab          \tab          \tab |           \tab |_ paramStr \cr
#'          \tab          \tab          \tab |_ poisson  \tab __ stat\cr
#'          \tab          \tab          \tab |           \tab |_ log \cr
#'          \tab          \tab          \tab |           \tab |_ paramStr \cr
#'          \tab          \tab          \tab |_ ...
#'
#' }
#'
#'
#' @examples
#' dataLearn <- list(
#'   var1 = as.character(c(rnorm(50, -2, 0.8), rnorm(50, 2, 0.8))),
#'   var2 = as.character(c(rnorm(50, 2), rpois(50, 8)))
#' )
#'
#' dataPredict <- list(
#'   var1 = as.character(c(rnorm(10, -2, 0.8), rnorm(10, 2, 0.8))),
#'   var2 = as.character(c(rnorm(10, 2), rpois(10, 8)))
#' )
#'
#' model <- list(
#'   var1 = list(type = "Gaussian", paramStr = ""),
#'   var2 = list(type = "Poisson", paramStr = "")
#' )
#'
#' algo <- list(
#'   nClass = 2,
#'   nInd = 100,
#'   nbBurnInIter = 100,
#'   nbIter = 100,
#'   nbGibbsBurnInIter = 100,
#'   nbGibbsIter = 100,
#'   nInitPerClass = 3,
#'   nSemTry = 20,
#'   confidenceLevel = 0.95,
#'   ratioStableCriterion = 0.95,
#'   nStableCriterion = 10,
#'   mode = "learn"
#' )
#'
#'
#' # run RMixtComp in unsupervised clustering mode + data as matrix
#' resLearn <- rmcMultiRun(algo, dataLearn, model, nRun = 3)
#'
#'
#' # run RMixtComp in predict mode + data as list
#' algo$nInd <- 20
#' algo$mode <- "predict"
#' resPredict <- rmcMultiRun(algo, dataPredict, model, resLearn)
#' @author Quentin Grimonprez
#' @export
rmcMultiRun <- function(algo, data, model, resLearn = list(), nRun = 1, nCore = 1, verbose = FALSE) {
  nCore <- min(max(1, nCore), nRun)

  if (nCore > 1) {
    if (verbose) {
      cl <- makeCluster(nCore, outfile = "")
    } else {
      cl <- makeCluster(nCore)
    }

    registerDoParallel(cl)
  } else {
    registerDoSEQ()
  }


  res <- foreach(i = 1:nRun) %dopar% {
    if (verbose) {
      cat(paste0("Start run ", i, " on thread number ", Sys.getpid(), "\n"))
    }

    resTemp <- rmc(algo, data, model, resLearn)
    class(resTemp) <- "MixtComp"

    # c++ index starts at 0, we add 1
    varNames <- names(resTemp$variable$data)
    for (name in varNames) {
      if (!is.null(resTemp$variable$data[[name]]$stat)) {
        resTemp$variable$data[[name]]$stat <- correctIndexCompletedStat(
          resTemp$variable$data[[name]]$stat,
          resTemp$variable$type[[name]]
        )
      }
    }

    if (verbose) {
      cat(paste0("Run ", i, " DONE on thread number ", Sys.getpid(), "\n"))
    }

    return(resTemp)
  }

  if (nCore > 1) {
    stopCluster(cl)
  }


  logLikelihood <- sapply(res, function(x) {
    ifelse(is.null(x$warnLog), x$mixture$lnObservedLikelihood, -Inf)
  })

  indMax <- which.max(logLikelihood)

  return(res[[indMax]])
}

# c++ index starts at 0, we add 1
correctIndexCompletedStat <- function(stat, model) {
  if (model %in% c("Gaussian", "Poisson", "NegativeBinomial", "Weibull")) {
    return(correctIndexCompletedStatNumerical(stat))
  }

  if (model %in% c("Multinomial", "Rank_ISR")) {
    return(correctIndexCompletedStatMultinomRank(stat))
  }

  return(stat)
}

correctIndexCompletedStatNumerical <- function(stat) {
  stat[, 1] <- stat[, 1] + 1

  return(stat)
}

correctIndexCompletedStatMultinomRank <- function(stat) {
  names(stat) <- as.numeric(names(stat)) + 1

  return(stat)
}



# rand index
rand.index <- function(partition1, partition2) {
  x <- abs(sapply(partition1, function(x) {
    x - partition1
  }))
  x[x > 1] <- 1

  y <- abs(sapply(partition2, function(x) {
    x - partition2
  }))
  y[y > 1] <- 1

  sg <- sum(abs(x - y)) / 2
  bc <- choose(dim(x)[1], 2)

  randIndex <- 1 - sg / bc

  return(randIndex)
}
