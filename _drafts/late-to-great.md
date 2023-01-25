---
name: LATE to Great
link: /assets/late-to-great/late-to-great.pdf
status: Dormant
---

This was my writing sample for grad school applications. The basic idea is to estimate treatment effect heterogeneity with very small subgroups by putting weak structure on the relationships across cells (in this case based on neighbor relationships on a lattice constructed over the covariate space). Relates to much better work on GMRF priors by [Gao, Kennedy,Simpson, and Gelman](https://projecteuclid.org/journals/bayesian-analysis/volume-16/issue-3/Improving-Multilevel-Regression-and-Poststratification-with-Structured-Priors/10.1214/20-BA1223.pdf) and [Gao, Kennedy, and Simpson](https://arxiv.org/abs/2102.10003). I discuss the structure of the priors and show in simulations that it can recover the shape of treatment effects over a covariate space very accurately even when subgroups are quite small. Further, I show an application to 2SLS; without structural priors 2SLS approaches infinite variance as the number of cells groups, but with structural GMRF priors this is no issue at all, even when the number of cells exceeds the number of data points.


