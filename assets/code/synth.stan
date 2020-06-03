data {
  int<lower=0> N; // number of observations
  int<lower=0> K; // number of parameters
  int<lower=0> J; // number of donor groups
  int<lower=0> N_future; // number of future observations
  vector[N] Y1; // vector of case study group outcomes
  vector[N * J] Y0; // matrix of donor group outcomes
  matrix[N, K] X1; // matrix covariates for case study
  matrix[N * J, K] X0; // matrix covariates for case study
  matrix[N_future, J] Y0_future;
  vector[N_future] Y1_future; // Future data predicted by model
}
parameters {
  real alpha;
  simplex[K] V; // weight parameters, simplex implies sum-to-1
  simplex[J] W; // weight parameters, simplex implies sum-to-1
  vector[N] synth_X; // synthetic X based on weight parameter
  real<lower=0> sigma; // variance parameter for outcomes
}
model {
  matrix[K, K] res;
  vector[N * (J + 1)] AllY;
  matrix[N * (J + 1), K] AllX;
  
  for(i in 1:J) {
    Y0_mat[,i] = 
  }
  
  res = X1 - X0 * diag_matrix(W);
  
  // linear regression model
  target += normal_lpdf(AllY | alpha + AllX * V, sigma);
  target += sqrt(res' * diag_matrix(V) * res);
  
}
generated quantities {
  vector[N_future] Y_pred; 
  vector[N_future] Y_resid;
  
  for(i in 1:N_future) {
    Y_pred[i] = Y0_future[i] * W;
    Y_resid[i] = Y1_future[i] - Y_pred[i];
  }
}

