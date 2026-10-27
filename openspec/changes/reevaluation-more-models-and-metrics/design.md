# Design

See proposal.md for why, the fit count, and the runtime.

## Decisions

Space-filling, not `tune_bayes`. The measured costs are `tune_grid` costs, and a size-40 Latin hypercube is fixed once the outer seed is set. `tune_bayes` would spend a similar number of 10 by 10 evaluations but the candidate list would depend on the path. Size 40 is the run; 30 and 50 only change the runtime, as calculated in the proposal.

Early stopping is a hold-out sliced from the analysis set of each resample. It does not see the assessment fold or the outer test set. The 10 by 10 still selects the candidate by balanced accuracy.

The fuller XGBoost search adds min_n, mtry, loss_reduction, and sample_size to tree_depth and learn_rate. Trees stay at 500, matching the light arm, so one candidate costs what one measured light-XGBoost grid point cost. It is a second arm pair (class weights and none). The nine-point arm is left in place, including ROSE.

LightGBM uses the same two arms and the same forty candidates. Trees, learn_rate, num_leaves, min_n, and the feature fraction (`mtry`, passed by bonsai as the lightgbm feature fraction) are the tuned arguments. One thread.

Score models use the integer quality 3–8 as the outcome and the same filtered predictors. Random forest keeps the existing nine-point `mtry` by `min_n` grid. Penalised linear regression keeps the logistic model's penalty by mixture grid. Score LightGBM uses the forty-candidate search. Selection inside the 10 by 10 calls high when the predicted score is at least 6.5. The reported cut is chosen afterwards on out-of-fold scores. There is no nested search.

Class weights, where used, are the training-split inverse-frequency weights already used for the other models. They are not recomputed on the test rows.

## Risks

- bonsai may ignore case weights. That cell is `unsupported`.
- Early stopping can shrink trees enough that LightGBM is faster than the XGBoost anchor. The estimate does not assume that.
- A scheduling collision in the old mtimes was excluded rather than averaged in. The anchors that remain are the cells whose five seeds agree.

## Open questions

None. The candidate count is 40, and the runtime at 30 and 50 is already stated.
