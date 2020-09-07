source("./renv/activate.R")
source("./packages/load.R", chdir = TRUE)
source("./utils/index.R", chdir = TRUE)

# cores <- parallel::detectCores(logical = TRUE) - 1
# doFuture::registerDoFuture()
# cl <- parallel::makeCluster(cores)
# future::plan(cluster, workers = cl)
# future::plan(multisession, workers = cores)

# source("libraries.R")