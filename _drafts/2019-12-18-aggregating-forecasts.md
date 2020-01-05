---
layout: post
title: Analysts & Meta-Analysts
tags: finance, meta-analysis, Bayes
---

One thing I've been thinking about is how to aggregate financial analyst forecasts. The essential job of an analyst is to forecast the price of a security (perhaps over different windows). Then they distill that to a recommendation (buy, sell, etc.). We might expect these analysts to be more or less sensitive to different sources of information, and also to have different default positions for their expectations of how a company will do. There is one true future price that is going to arise as a function of changes in expectations of future earnings, price momentum, sales, or whatever. Some mix of characteristics.

Even more vague is how to properly aggregate forecasts for asset classes as a whole! Different companies come out with "capital market assumption" forecasts that are based on entirely opaque models or in the worst case scenario just a gut feeling. The Bayesian in me wants people to give some kind of distribution on both their expectation of the mean _and_ the variance, but ultimately these types of "expert" (e.g. non-model-based) forecasts are hard enough as is. That makes it difficult to appropriately propogate the uncertainty in the forecasts into the aggregated forecasts.

# A motivating example

As a simple example (this is something people actually do), we might just take an average of the forecasts for the mean and the variance. Then those get plugged into our mean-variance optimizer, and we end up with some asset allocation. But suppose that we have 3 analysts that were asked to give point forecasts about the returns and standard deviations of some asset class over the next year.

| Metric   | Amy | Bob | Carla |
|----------|-----|-----|-------|
| Mean     | 0.08| 0.06| -0.05 |
| Std. Dev.| 0.01| 0.02| 0.06  |

Carla clearly expects some kind of correction, Bob expects close to average returns, and Amy thinks there's going to be very good risk adjusted returns. Does the volatility of Carla imply greater uncertainty? Or just bad risk-adjusted return? Perhaps Carla is actually very confident about the average, but also thinks that volatility is going to spike!

Now even without a direct measure of uncertainty in their predictions of the mean, we still need to take into account the level of disagreement between the analysts in our forecast of the asset classes returns. We might assume that returns $y$ are given by 

$y = \mu + \epsilon$

and the mean is given by some aggregated mean around the forecast. Suppose that we use the average of the three predicted standard deviations (0.03) as our volatility forecast, e.g. $\epsilon \sim Normal(0, 0.03^2)$, and the standard error of a naive mean estimator as our uncertainty about $\mu$. In other words

$\mu \sim Normal(0.03, \dfrac{0.07^2}{3})$

Then $y_{forecast} \sim Normal(0.03, \dfrac{0.07^2}{3} + 0.03^2)$, or a standard deviation of about 0.05 for the forecasted $y$. This would be a very simple thing to do, but is also likely to _underestimate_ the uncertainty in the forecasts. We'll see why in a second.

# Analysts and Meta-analysis

## Meta-analysis

Meta-analysis, or the process by which we aggregate conclusions of different studies, has a very similar problem as CMA forecasts. In an ideal setting we would have access to the underlying data and modeling process, and we could aggregate at that level, adjusting for differences in study design along the way. However, we often only have access to the rough measurements that the studies have published.

So we might only have access to a series of published means and standard errors for an estimate of some kind of treatment effect. At the same time, the actual structure of the studies and differences in the underlying studied populations might be entirely obscured. One of the canonical models for how to aggregate these effects assumes that each measured effect is randomly drawn from some distribution. 


In other words while the measured treatment effect in study $i$ is given by

$y_i \sim Normal(\theta, \sigma_i)$

where $\sigma_i$ is the standard error of the measured effect in study $i$, we also presume that $\theta$ is given by 

$\theta \sim Normal(\mu, \tau)$,

where $\tau is the variance of the meta-distribution that the measuremed treatment effects are drawn from and $\mu$ is the unobserved true effect being measured by the studies.

Now this normal distribution seems like a fiction, and in some ways it is, but it also is a useful assumption that allows us to actually aggregate our estimates, all the while propogating our uncertainty of each studies measurements forward into our aggregate effect estimate. Another way to think about this is that without additional information about each study, the differences between them are ignorable. Thus we can exchange one study for another without messing up our analysis. If we had more information about the various studies we would certainly want to model them!

## Analysts

Analysts or other forecasters have largely the same issue. J.P. Morgan (or Goldman Sachs, or an internal team for a buy-side firm) comes out with a forecast for equity returns for the next year, but we don't really know what type of information they are using to forecast it. I, without more information, don't really feel comfortable judging the particular quality of that information.