---
layout: post
title: Fast Quantile Regression with fqr
tags: quantiles, R
---

Quantile regression is a useful workhorse model for modeling distributional effects, but it tends to be slow for large problems. So I built an R package that makes it fast! I'll do a blog post describing exactly how the whole thing works in a bit, but for now I just figured I'd share this now that it's up and running.

[You can find the package here.](https://github.com/be-green/fqr).

The basic idea is that you can get an arbitrarily good approximation of the quantile loss function which happens to be smooth. And since the function is convex, optimization becomes really easy! I'm definitely not the first person to realize this, but I didn't see any implementations out there that I liked, and none of them were using accelerated gradient descent (which can be substantially faster than regular gradient descent). 

Right now standard errors come from subsampling, but I haven't tested those a ton. If you find any bugs or things that raise some flags for you, please email me or submit a github issue!
