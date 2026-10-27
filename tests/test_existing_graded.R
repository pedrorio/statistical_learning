# The graded files are only read: same bytes as b86768e, in the working tree
# and in the index, and the committed main.pdf hash.
graded <- c("fit.R", "utils/recipes/step_recipe.R", "main.pdf", "conclusion")
stopifnot(identical(unname(tools::md5sum("main.pdf")), "2848ef7280e31c430dfd9f3e1fc66ebb"))
stopifnot(system2("git", c("diff", "--quiet", "b86768e", "--", graded)) == 0)
stopifnot(system2("git", c("diff", "--quiet", "--cached", "b86768e", "--", graded)) == 0)
message("existing graded: ok")
