---
layout: post
title: Style Analysis + Decision Theory
tags: finance, Stan, Bayes
---

In my last blog I talked about the use of uncertainty from a decision-theoretic perspective, but I really know almost nothing about Bayesian decision theory. Since then I've done some reading, and here's my quick understanding of why we might want to use the full posterior.

Posterior distributions represent the "generative" model for the phenomenon. For now we will constrain ourselves to using the output of a single model. The premise of decision theory in the context of the posterior is to pick the act (the set of portfolio weights) that maximizes expected utility of the consequences of that act. In the case of point estimation, we have utility associated with being right vs. wrong (or close vs. far away). Since the posterior draws represent the states of the world, in principle you should be able to approximate the utility of an action by taking the average utility at each point in the posterior, given the chosen act. 

To determine what type of point estimate we want to move forward with (in this case those estimates directly represent potential portfolio weights), we need to define a utility or loss function (a loss function being a negative utility function). Then we pick the estimate that maximizes utility.

Most loss functions will not have a closed-form solution, but there are a few important ones that do.

