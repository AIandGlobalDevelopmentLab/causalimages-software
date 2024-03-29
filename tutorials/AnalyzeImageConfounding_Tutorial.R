#!/usr/bin/env Rscript

################################
# Image confounding tutorial using causalimages
################################

# remote install latest version of the package if needed
# devtools::install_github(repo = "cjerzak/causalimages-software/causalimages")

# local install for development team
# install.packages("~/Documents/causalimages-software/causalimages",repos = NULL, type = "source",force = F)

# load in package
library( causalimages  )

# load in tutorial data
data(  CausalImagesTutorialData )

# example acquire image function (loading from memory)
# in general, you'll want to write a function that returns images
# that saved disk associated with keys
acquireImageFromMemory <- function(keys, training = F){
  # here, the function input keys
  # refers to the unit-associated image keys
  m_ <- FullImageArray[match(keys, KeysOfImages),,,]

  # if keys == 1, add the batch dimension so output dims are always consistent
  # (here in image case, dims are batch by height by width by channel)
  if(length(keys) == 1){
    m_ <- array(m_,dim = c(1L,dim(m_)[1],dim(m_)[2],dim(m_)[3]))
  }

  return( m_ )
}

# example video function (this here just appends two identical images (with one rotated) for illustration only)
# in practice, image sequence / video data will be read from disk
acquireVideoRepFromMemory <- function(keys, training = F){
  tmp <- acquireImageFromMemory(keys, training = training)

  if(length(keys) == 1){
    tmp <- array(tmp,dim = c(1L,dim(tmp)[1],dim(tmp)[2],dim(tmp)[3]))
  }

  tmp <- array(tmp,dim = c(dim(tmp)[1],
                           2,
                           dim(tmp)[3],
                           dim(tmp)[4],
                           1L))
  return(  tmp  )
}

# drop first column
X <- X[,-1]

# mean imputation for simplicity
X <- apply(X,2,function(zer){
  zer[is.na(zer)] <- mean( zer,na.rm = T )
  return( zer )
})

# select observation subset to make tutorial analyses run faster
take_indices <- unlist( tapply(1:length(obsW),obsW,function(zer){sample(zer, 50)}) )

# uncomment for a larger n analysis
#take_indices <- 1:length( obsY )

# perform causal inference with image and tabular confounding
ImageConfoundingAnalysis <- AnalyzeImageConfounding(
  obsW = obsW[ take_indices ],
  obsY = obsY[ take_indices ],
  X = X[ take_indices,apply(X[ take_indices,],2,sd)>0],
  long = LongLat$geo_long[ take_indices ],
  lat = LongLat$geo_lat[ take_indices ],

  imageKeysOfUnits = KeysOfObservations[ take_indices ],
  acquireImageFxn = acquireImageFromMemory,
  batchSize = 4,
  #modelClass = "cnn", # uses convolutional network (richer model class)
  modelClass = "embeddings", # uses image embeddings (faster)
  file = NULL,
  plotBands = c(1,2,3),
  dropoutRate = 0.1,
  tagInFigures = T, figuresTag = "TutorialExample",
  nBoot = 10,
  nSGD = 10, # this should be more like 1000 in full analysis
  figuresPath = "~/Downloads", # figures saved here
  conda_env = "tensorflow_m1", # conda env to activate where a version of tensorflow lives
  conda_env_required = T
)

# ATE estimate (image confounder adjusted)
ImageConfoundingAnalysis$tauHat_propensityHajek

# ATE se estimate (image confounder adjusted)
ImageConfoundingAnalysis$tauHat_propensityHajek_se

# some out-of-sample evaluation metrics s
ImageConfoundingAnalysis$ModelEvaluationMetrics
