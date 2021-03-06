# Define a rough equivalent to proc genmod's estimate statement.
# The 'fit' argument is your model object.
# The 'combos' argument specifies linear combinations of parameter estimates.
estimate <- function(fit, combos) {
  # Compute the mean estimate
  est <- combos %*% coef(fit)
  
  # Get the appropriate variance estimate
  if (with(fit$geese, all(weights == 1) & max(clusz) == 1))
    var <- fit$geese$vbeta.naiv
  else var <- fit$geese$vbeta
  
  # Compute standard error of mean estimate and confidence bounds
  se.est <- sqrt(diag(combos %*% var %*% t(combos)))
  lcl <- est - se.est * qnorm(0.975)
  ucl <- est + se.est * qnorm(0.975)
  
  # Perform a 1-degree-of-freedom Wald test on the estimate
  pvalue <- 1 - pchisq((est/se.est)^2, df = 1)
  
  # Combine and format output
  out <- cbind(est, lcl, ucl, se.est, pvalue)
  rownames(out) <- rownames(combos)
  colnames(out) <- c("Estimate", "95% LCL", "95% UCL", "SE", "p-value")
  class(out) <- "estimate"
  out
}

cat("function 'estimate' loaded successfully.\n")

# Define a print function for the "estimate" class created above 
print.estimate <- function(object, digits = 4, signif.stars = FALSE, ...) {
  ## print 4 decimal places by default, like SAS
  printCoefmat(round(object, digits = digits), digits = digits + 1,
               signif.stars = signif.stars, has.Pvalue = TRUE,
               eps.Pvalue = 0.0001, ...)
}