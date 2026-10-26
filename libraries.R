source("./renv/activate.R")
source("./packages/load.R", chdir = TRUE)
source("./utils/index.R", chdir = TRUE)

# One seed for the whole project. Kept last so sourcing the loader resets RNG.
set.seed(2020)

# cores <- parallel::detectCores(logical = TRUE) - 1
# doFuture::registerDoFuture()
# cl <- parallel::makeCluster(cores)
# future::plan(cluster, workers = cl)
# future::plan(multisession, workers = cores)

# source("libraries.R")