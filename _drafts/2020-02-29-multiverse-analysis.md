---
layout: post
title: Multiverse Analysis, Shiny Edition
tags: reproducibility, R
---

I'm currently working on a package that implements regression discontinuity designs. If you are unfamiliar, regression discontinuity is a non-parametric approach to estimating a causal parameter where groups are separated into treatment and control based on an arbitrary boundary. For example, maybe Yelp rounds the number of stars they report for a restaurant to the nearest integer (pretty sure they don't, but go with it). Well, for restaurants with enough reviews, there might be a true underlying average stars of 4.499, and there might be another with a true underlying average of 4.5001. One gets rounded up, one gets rounded down.

Assuming restaurants are unable to manipulate how they are rounded, this would let us analyze the impact of having an additional star on Yelp on some kind of outcome variable. Perhaps something like total sales, or profits, or customers checking in. If that assumption is a bad one, then we run into issues.

Regression discontinuity designs are extremely popular in economics, but they also suffer from [researcher degrees of freedom](https://pdfs.semanticscholar.org/b63e/25900013605c16f4ad74c636cfbd8e9a3e8e.pdf). This is to say that there are a large number of points where researchers have control over the specification. Generally researchers choose a specific distance away from the cutoff (4.5) to include in the regression equation that measures the discrepancy at the point itself. Before that, they can choose how they want to "bin" the observations on either side of the discrepancy. They can also choose the specific type of regression they want to run.

The vast majority of the time, I think people do not intentionally choose the hyperparameters of their regression discontinuity design to get the outcome they want. At the same time, researchers don't always follow the same practices, and as an external observer it is hard to know exactly to what extent a the researcher's path of discovery influenced the result. After all, traditional hypothesis tests are not calibrated based on the true frequencies that researchers perform them. They are largely meant for tests of a single experiment.


The research process, especially with non-experimental data, is a mix between exploration and testing. In general I think this is a really good thing--exploring data can show us things that we can later test more extensively. But it does present problems for frequency tests, which never condition on the excitement of the researcher when they start to find things.

Brian Nosek, Jeffrey Spies, and Matt Motyl [relate a fantastic story](https://journals.sagepub.com/doi/full/10.1177/1745691612459058) about exploratory data analysis which they later replicated. While the first time they analyzed the data they had a publishable result, they decided it was cheap and feasible enough to redo the experiment. When they had the hypothesis fully set before running the experiment, the measured effect (that people who had strong political partisanship had trouble seeing shades of grey, literally) vanished entirely.

Unfortunately, very little work in Economics is easy to re-run (perhaps with the exception of true randomized controlled trials). There are serious ethical issues with inducing recessions at random times, for example. It's also unclear how we would even go about doing that in a way that we could actually analyze. If we had such a clean experimental design, we wouldn't need regression discontinuity designs in the first place!

So then, if we can't replicate our analysis, what is left? The package I'm building, [shinyrd](https://github.com/be-green/shinyrd), will implement pretty much all of the state of the art tech for regression discontinuity design. People will be able to do the kernel regressions, local polynomials, density tests, visualizations, etc. But more than that, it will create an easily shareable and packaged analysis that researchers can publish to the web, allowing others to pick their own specifications.

What does this have to do with the multiverse? What matters in the case of researcher degrees of freedom is the _number of potential comparisons_ in the dataset. For a great example, [researchers re-analyze a published study, walking through all potential comparisons](https://journals.sagepub.com/doi/full/10.1177/1745691616658637). With something that is fundamentally a continuous phenomenon, this is extra-ordinarily difficult. You have to make choices about what set of comparisons in the multiverse are "reasonable."

In the case of regression discontinuity, instead I'm proposing that we package the analysis in a way where researchers don't necessarily have to share the underlying data, but other academics can run every other possible specification that could reasonably be considered in published work. This type of application normally takes a lot of programming skills, so I'm going to build a "shinyrd" function, which given the data will allow users to choose the cutoff, run density tests, run simulations from the fitted RD model, output tables and plots, do covariate balance checks, etc. Basically everything you could ever want to see! Then it will include code to automatically package the shiny application and publish it to a site like [shinyapps.io](https://www.shinyapps.io) or an RStudio Connect server for other researchers to look at and consume.

This is not even in alpha yet (I've only just implemented the most basic tests), but more to come! If you have thoughts, drop me a line.