---
layout: post
title: An Uninformative Post on Priors
---

As a largely self-taught statistician, after some years of practicing both frequentist and Bayesian methods of inference, I find myself increasingly drawn to the notion that we _always_ have some form of information about the problem at hand. This is not to say we know anything quite strong, but in any problem there are a class of parameter values which we would reject out of hand. This is to say, if I were to run an OLS regression and get back a $\beta$ estimate of 2,000, I would simply think that I had done something wrong. And if I had not, without further evidence I would be inclined to think that this was merely a product of a very strange selection of sample for the estimate or that there is something that I have failed to include in my model. Just to make sure this looks strange, I might simulate a bunch of data given the data generating process

$$R = \alpha + \beta X + \epsilon $$

which would give me egregiously large returns relative to my best understanding.

It might be good not to entirely throw away this type of estimate--perhaps there will one day be a company that truly has 2000x the systemic risk of the total market--but it does seem unlikely at the very least. I would also argue that there are very few financial economists who would run away from this principle. Indeed, it is common practice with financial assets to perform this kind of regularization ad-hoc, playing with the windows of estimation or data frequency to get better estimates of risk exposures.

You can obviously have a bad prior, but you can obviously fit a bad model. Discourse about what to include or exclude from models 

