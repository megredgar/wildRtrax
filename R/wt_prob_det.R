#' Estimate the probability of detection, given a location is occupied, based on the audio survey length and the number of surveys conducted.
#'
#' @description Using data from the ABMI ecosystem health acoustic surveys (2015-2020), occupancy models were fit to five common boreal songbirds. These models are used to estimate the detection probability for each species for surveys of different lengths (1-3 minutes).
#' Given that it is present, these results can be used to estimate the probability the species will be detected at least once as a function of the number of surveys conducted.
#'
#' @param species_code Character; the species code. See below for included species.
#' @param survey_length Double; the survey length in minutes. Valid values are 1, 2, and 3.
#' @param number_of_surveys Double; the number of surveys (to be) conducted.
#' @details Valid values for species_code currently include:
#' \itemize{
#'  \item "OVEN" (Ovenbird)
#'  \item "CCSP" (Clay-colored Sparrow)
#'  \item "OSFL" (Olive-sided Flycatcher)
#'  \item "TEWA" (Tennessee Warbler)
#'  \item "WTSP" (White-throated Sparrow)
#'  \item "ALFL" (Alder Flycatcher)
#'  \item "LISP" (Lincoln's Sparrow)
#'  \item "YRWA" (Yellow-rumped Warbler)
#'  \item "CONI" (Common Nighthawk)
#'  \item "SWTH" (Swainson's Thrush)
#'  \item "WOLF" (Gray Wolf)
#'  \item "GGOW" (Great Gray Owl)
#'  \item "GHOW" (Great Horned Owl)
#'  \item "NSWO" (Northern Saw-whet Owl)
#'  \item "SEOW" (Short-eared Owl)
#' }
#'
#' @importFrom unmarked backTransform
#' @export
#'
#' @examples
#' \dontrun{
#' wt_prob_det(species_code = "OVEN", survey_length = 1, number_of_surveys = 4)
#' }
#'
#' @return Double; the estimated probability of species detection based on the number of surveys planned.

wt_prob_det <- function(species_code, survey_length, number_of_surveys) {

  # Retrieve detection models
  data("detection_models", envir = environment())

  # Check that a valid species code was supplied
  valid_codes <- c('OVEN', 'OSFL', 'CCSP', 'TEWA', 'WTSP', 'ALFL', 'CONI', 'SWTH', 'LISP', 'YRWA', 'WOLF', 'GGOW', 'GHOW', 'SEOW', 'NSWO')
  if(!species_code %in% valid_codes) {
    stop("Please supply a valid species code (species_code). See ?wt_prob_det for valid species.", call. = TRUE)
  }

  # Check that survey length is 1, 2, or 3 minutes
  survey_length <- as.numeric(survey_length)
  valid_lengths <- c(1, 2, 3)
  if(!survey_length %in% valid_lengths) {
    stop("Survey length (survey_length) must be 1, 2, or 3 minutes.", call. = TRUE)
  }

  # Combine species code and survey length
  x <- paste0(species_code, survey_length)

  # Select model
  mod <- detection_models[[x]]
  # Estimate detection probability per survey
  prob <- unmarked::backTransform(mod, 'det')@estimate

  # Estimate probability of species detection based on number of surveys
  number_of_surveys <- as.numeric(number_of_surveys)
  y <- 1 - ((1 - prob) ^ number_of_surveys)

  return(y)

}

#' Run prob_det function API
#'
#' @param ... Options passed to \code{plumber::plumb()$run()}
#' @examples
#' \dontrun{
#' run_prob_det_api()
#' }
#'
#' @importFrom plumber plumb
#' @return A running Plumber API
#' @export
#'
run_prob_det_api <- function(...) {

  plumber::plumb(dir = system.file("plumber", "prob_det", package = "wildRtrax"))$run(...)

}

#' Run a wildRtrax Shiny App (locally)
#'
#' @description Choose a shiny app included as part of the wildRtrax package and run it locally
#'
#' @param app Character; name of the shiny app.
#' @import shiny
#' @export
#' @example
#' \dontrun{wt_run_shiny(app = "prob_det")}
#'
#' @return A shiny app running locally

wt_run_shiny <- function(app) {

  # Locate all Shiny apps in the package
  apps <- list.files(system.file("shiny", package = "wildRtrax"))
  msg <- paste0("Valid Shiny apps from wildRtrax include: '", paste(apps, collapse = "', '"), "'")

  # Error if a invalid app is provided
  if (missing(app) || !nzchar(app) || !app %in% apps) {
    stop("Please run `wt_run_shiny()` with a valid app as an argument.\n",
         msg,
         call. = FALSE)
  }

  # Find app
  app_directory <- system.file("shiny", app, package = "wildRtrax")
  # Run app
  shiny::runApp(app_directory, display.mode = "normal")

}




