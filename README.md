# Statistical Learning

[IST](https://tecnico.ulisboa.pt/en/)

[MECD](https://fenix.tecnico.ulisboa.pt/cursos/mecd)

[Statistical Learning](https://fenix.tecnico.ulisboa.pt/disciplinas/AEsta4/2019-2020/2-semestre/)

# Grade

[Project](https://github.com/pedrorio/statistical_learning) : 18.0/20.0

## The original work, untouched

Classify red Vinho Verde as high or low quality from its physicochemical measurements. `data/winequality-red.csv` has 1599 rows: quality 3-6 is low (1382) and 7-8 is high (217), as in section 2.1. The IST MECD course project was graded 18.0/20.0, and `main.pdf` and its conclusion stay as graded. The report does not name a single winner: it says the radial SVM, logistic regression and flexible discriminant analysis did best. The radial SVM had the top test accuracy, 84.95% (Table 3.1). That is below the 86.43% you get by calling every wine low (1382/1599), which is why the re-evaluation scores on balanced accuracy.

## The re-evaluation

Every family is refit with the same 10x10 cross-validation and the same SVM grids, selected on balanced accuracy with high quality as the event. Cut-offs are tuned on out-of-fold scores, results are reported as paired differences against the radial SVM, and reruns reproduce exactly.

## Trying to beat it

The radial SVM remains the reference model at balanced accuracy 0.847. The stack scored 0.849, but its 0.002 edge held on only 3 of 5 splits, so the drop rule fixed in advance rejected it. The best GAM arm, with class weights, reached 0.821, and 0.812 without resampling. A GAM term is called curved only if its degrees of freedom stay clearly above 1 on every split and arm.

## What the tests caught

Any failed fit crashed the whole run, and the stored guess-low PR AUC was 0.569 when it should be 0.137. Both are fixed, with tests. PR AUC figures appear only from results produced after that fix.
