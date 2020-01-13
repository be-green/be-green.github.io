---
layout: post
title: Bayesian Style Analysis
tags: finance, Stan, Bayes
---

Sharpe's [style analysis](https://web.stanford.edu/~wfsharpe/art/sa/sa.htm) remains a workhorse took for people in industry who are looking to figure out what a fund's risk exposures are while constraining these exposures to long-only positions. This is typically implemented as a quadratic programming problem that finds the optimum (least squares) solution under constraints.

But we could also think of it as a regression with parameter regularization via informative priors. Indeed, Sharpe himself discusses this as a means to improve out of sample fit:

> It is important to recognize that [$R^2$] indicates only the extent to which a specific model fits the data at hand. A better test of the usefulness of any implementation is its ability to explain performance out-of-sample. For this reason it is important to consider not only the ability of a model to explain a given set of data but also its parsimony. Other things equal (e.g. R-squared values), the fewer the asset classes, the more likely is the model to represent continuing fundamental relationships with predictive content.

And subsequently, 

> The addition of constraints reflecting the fund's actual investment policy causes a slight reduction in the fit of the resulting equation to the data at hand (i.e., a decrease in R-squared to 92.22%). Now, however, the coefficients conform far more closely to the reality of the fund's investment style, making the resulting characterization more likely to provide meaningful results with out-of-sample data.

In other words, we want a model that we know to be consistent with the investment policy of a manager (we have external knowledge we bring to bear on the problem) and we want to replicate their forward-looking performance as best we can while still adhering to their policy. 

# A Bayesian Interpretation

We can formulate this optimization problem in terms of a generative Bayesian model. Given a matrix of $k$ factor returns $X$ measured $t$ times and a vector of fund returns $R$ (in log-space) we can formulate the problem as 

$R = \beta X + \epsilon$

where there is a point-mass prior on the sum of $\beta$, e.g.

$p(\Sigma_{i=1}^k \beta = 1) = 1$

and a uniform constraint on each $\beta_i$ such that

$\beta_i \sim Uniform(0,1)$

for each $i \in {1, ..., k}$.

Now this gets us nothing new vs. Sharpe's original approach. Really the only thing it can do is provide a mechanism for estimating [confidence intervals](https://www.tandfonline.com/doi/abs/10.2469/faj.v53.n4.2103?casa_token=JPIQPM5YRKgAAAAA:28lm8wO0SfEukcdjTrV3ALfw7PFqwnrKTMk_eK74qW2NmYEtDTun-5bYnL5M8U9Ps2Idd11Aqtc) of the style weights, which are going to be inherently asymmetric. This is a serious problem with existing methods, but because the posterior distribution is fully generative we can just simulate from it to determine the uncertainty in our weights.

In other words, if we want to quantify our uncertainty about each parameter in the style analysis (as in the linked article) we don't need an approximate formula for symmetric standard errors. We can also easily accomodate the behavior at the tails.

## Coding the model

I'm using [Stan](https://mc-stan.org) to code the model. The simplex statement implies a sum-to-1 constraint, and the uniform(0,1) prior implies constraints on each individual $\beta$. I am transforming the raw returns into log returns because this linearizes the return series (which otherwise compound geometrically and are constrained at -1). In order to test the fit of the model I am transforming back the simulated log returns into normal, geometric returns.

```
data {
  int<lower=0> N; // length of time
  int<lower=0> K; // number of factors
  matrix[N, K] X; // factor matrix
  vector[N] R; // vector of returns
}
parameters {
  real alpha;
  simplex[K] beta; // beta parameters, simplex implies sum-to-1
  real<lower=0> sigma; // variance parameter
}
model {

  // positive and maximum constraints
  for(k in 1:K) {
    beta[k] ~ uniform(0, 1);
  }

  // linear regression model
  R ~ normal(alpha + X * beta, sigma);
}
generated quantities {
  vector[N] R_rep;
  for(n in 1:N) {
    R_rep[n] = normal_rng(alpha + X[n,] * beta, sigma);
  }
}
```

While this isn't the most interesting observation in the sense that it gets us back to the same estimate as the version optimized with quadratic programming, it allows us to do a couple interesting things. First, we get standard errors, correlations, etc., for free. We don't need to derive formulas for approximate forward looking variances of asset betas (and thus asset weights). We can just use the posterior distribution.

Secondly, once we frame the problem this way, we can easily add more prior information or weaken prior information as might be appropriate. For example, if we know a fund has leverage, we might put a prior on the sum of the weights that takes into account the maximum amount of leverage they are allowed by policy, weakening the specific sum of the weights.

Finally, we can see some of the pathologies induced by the prior when we examine the poserior draws. These aren't inherently something terrible, but we see that the mean and median of the posterior are quite far from the mode! If we were forced to choose a portfolio to replicate the strategy given the style weights, how would we choose?

So to start, let's compare our fit to the implementation from the [FactorAnalytics]() R package that contains a pre-built function that solves the problem using quadratic programming. I'm going to grab some relevant fund and index data using the [quantmod]() package, that uses the Yahoo and/or Google Finance APIs to get daily price series. Because I know the fund fairly well, let's test this with AMCAP Fund class A.

Here are the functions I'm using to grab relevant index data. I've decided to use daily closing prices for my return series, and I calculate the returns using the PerformanceAnalytics package.
```
library(quantmod) # yahoo finance
library(PerformanceAnalytics) # performance calculations
library(magrittr) # ceci n'est pas une pipe
library(rstan) # for fitting the stan model

get_price <- function(symbol) {

  sym_name <- gsub("[^A-Za-z]", "", symbol)
  sym <-
    getSymbols(symbol, auto.assign = F)

  colnames(sym) <- gsub(paste0(sym_name, "."),
                         "",colnames(sym), fixed = T)

  sym <- sym[,"Close"]
  colnames(sym) <- sym_name
  sym[]
}

get_prices <- function(symbols) {
  Reduce(merge, lapply(symbols, get_price))
}

# S&P 500, Russell 2k, 90 day treasuries,
# 5 year treasuries, 10 year treasuries, 30 year treasuries,
idx <- c("^GSPC", "^RUT", "^IRX",
         "^FVX", "^TNX", "^TYX")

# a couple random mutual funds
# AMCAP Fund A and Wasatch-Hoisington US Treasury Fund
fund <- c("AMCPX", "WHOSX")

calc_returns <- function(symbols) {
  get_prices(symbols) %>%
    .[complete.cases(.),] %>%
    Return.calculate(.)
}

idx_returns <- calc_returns(idx)

fund_returns <- calc_returns(fund)
```

This gives us a matrix of index returns and fund returns, which we then want to pass to Stan for sampling (and to FactorAnalytics for optimizing). I built a function that converts this to data for the Stan script above before being passed through for optimization or MCMC sampling.

```

# function for turning this into
# a list that our stan model can use
make_standata <- function(fundRet, idxRet) {
  # save which is which
  idxNames <- colnames(idxRet)
  fundNames <- colnames(fundRet)

  # only use periods where they both have returns
  joint_ret <- merge(idxRet, fundRet) %>%
    .[complete.cases(.),]

  list(
    N = nrow(joint_ret),
    K = length(idxNames),
    X = as.matrix(log1p(joint_ret[,idxNames])),
    R = as.vector(log1p(joint_ret[,fundNames]))
  )
}

# compile model
# requires the stan file to be
# in the working directory
style_reg <- stan_model("bayesian-style.stan")

# create data
# daily returns
amcap_style_data <-
  make_standata(fund_returns$AMCPX,
                idx_returns)

# weights should be the same
FactorAnalytics::style.fit(log1p(amcap_style_data$R),
                           log1p(amcap_style_data$X))

# MCMC sampling
amcap_fit <- sampling(style_reg, data = amcap_style_data)
```

Here is the output from the FactorAnalytics optimization:

| GSPC|  RUT| IRX| FVX| TNX|  TYX|
|----:|----:|---:|---:|---:|----:|
| 0.89| 0.07|   0|   0|   0| 0.04|

And here is the output from `stan::optimizing()` (once I set up the tuning parameters to be a little more sensitive to the relative gradient and value changes of the objective function).

| GSPC|  RUT| IRX| FVX| TNX|  TYX|
|----:|----:|---:|---:|---:|----:|
| 0.89| 0.07|   0|   0|   0| 0.04|

So we have agreement! But what I particularly like about this approach is that we can get direct confidence intervals for our parameters via MCMC sampling. I would speculate that with daily returns and Metropolis-Hastings this might have taken a while, especially if there was weird geometry induced by the priors, but with Stan and HMC it's pretty fast. The whole thing (with simulated posterior draws) takes about 2 minutes. We also end up with the same answer (in expectation)

```
Inference for Stan model: bayesian-style.
4 chains, each with iter=2000; warmup=1000; thin=1; 
post-warmup draws per chain=1000, total post-warmup draws=4000.

                mean se_mean   sd     2.5%      25%      50%      75%    97.5% n_eff Rhat
alpha           0.00    0.00 0.00     0.00     0.00     0.00     0.00     0.00  4268    1
beta[1]         0.89    0.00 0.01     0.87     0.88     0.89     0.90     0.91  1977    1
beta[2]         0.07    0.00 0.01     0.05     0.06     0.07     0.08     0.09  1690    1
beta[3]         0.00    0.00 0.00     0.00     0.00     0.00     0.00     0.00  3507    1
beta[4]         0.00    0.00 0.00     0.00     0.00     0.00     0.00     0.00  3485    1
beta[5]         0.00    0.00 0.00     0.00     0.00     0.00     0.00     0.00  3937    1
beta[6]         0.04    0.00 0.00     0.03     0.03     0.04     0.04     0.05  4493    1
```

The indexes are listed in the same order as the previous column names. We can also visualize this by plotting kernel density estimates of the parameters.

![amcap-plot](bayesian-style/initial-amcap-plot.png)

In this case it looks like the confidence intervals are fairly symmetric, but this type of prior introduces potentially pathological correlations in the posterior as the values rub up against the boundaries. For example, if I include correlated assets that make up the majority of the portfolio, like the Russell 1000 Value, the Russell 1000 Growth, and the S&P 500, I get some weird-looking results where the posterior mode is no longer equivalent to the expectation.


## Priors for Testing Constraints, Accomodating Odd Strategies, and Inducing Sparsity

There may be strategies where we want to encode fundamentally different information that Sharpe did in his analysis. For example, we may have a 130/30 fund, which can take on leverage. Or a hedge fund, which is less constrained altogether. In this formulation, we might weaken our priors on the sum of the $\beta$ parameters, or allow $\beta$ to vary across a larger region.

It may also be the case that we want to test our specification. If we aren't including the appropriate type of assets in our model, our $\beta$ parameters may be pushing against our priors fairly heavily, wanting to be much greater or less than 1 (or perhaps negative). If this is true and we _know_ that the strategy is long-only, we probably want to take another look at our model.

```
data {
  int<lower=0> N; // length of time
  int<lower=0> K; // number of factors
  matrix[N, K] X; // factor matrix
  vector[N] R; // vector of returns
}
transformed data {
  vector<lower=0>[N] R1p = log1p(R);
  matrix<lower=0>[N, K] X1p = log1p(X);
}
parameters {
  real alpha;
  vector[K] beta; // beta parameters, simplex implies sum-to-1
  real<lower=0> sigma; // variance parameter
}
model {

  // positive and maximum constraints
  // I think that the simplex statement specifies this anyway
  // but maybe this helps make it clear?
  for(k in 1:K) {
    beta[k] ~ uniform(0, 1);
  }

  // weaker constraint that might help identify pathologies
  sum(beta) ~ normal(0, 0.01)

  // linear regression model
  R1p ~ lognormal(alpha + X1p * beta, sigma);
}
generated quantities {
  vector[N] R_rep;
  for(n in 1:N) {
    R_rep[n] = expm1(lognormal_rng(alpha + X1p[n,] * beta,
    sigma));
  }
}
```

## Extending the model

Now that we have a framework that treats this type of analysis as a complete generative model, rather than a constrained optimization problem, incorporating additional information we have about the moments of the return-generating distribution. For example, it is well known that volatility is correlated across time 

