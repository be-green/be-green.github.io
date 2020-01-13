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
