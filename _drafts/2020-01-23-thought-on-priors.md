---
layout: post
title: An Uninformative Post on Priors
---

## There is always information

I'm largely a self-taught statistitician, so it is entirely possible that everything I'm about to say is either well-known or utterly false. But after some time practicing both frequentist and Bayesian methods of inference, I find myself increasingly drawn to the notion that we (as people) _always_ have some form of information about the problem at hand. This is not to say we know anything quite strong, but in any problem there are a class of parameter values which we would reject out of hand. And if we really believe ourselves to be uninformed, it might be better to think about it for a while.

This is to say, if I were running OLS regression of a security against a market cap weighted index and get back a $\beta$ estimate of 2,000, I would simply think that I had done something wrong. And if I had not, without further evidence I would be inclined to think that this was merely a product of a very strange selection of sample for the estimate or that there is something that I have failed to include in my model. Just to make sure this looks strange, I might simulate a bunch of data given the data generating process

$R_t = \alpha + \beta X_t + \epsilon_t$

which would give me egregiously large returns relative to my best understanding.

It might be good not to entirely throw away this type of estimate--perhaps there will one day be a company that truly has 2000x the systemic risk of the total market--but it does seem unlikely at the very least. I would also argue that there are very few financial economists who would accept a market $\beta$ estimate of 2000. Indeed, it is common practice with financial assets to perform this kind of regularization ad-hoc, playing with the windows of estimation or data frequency to get better estimates of risk exposures.

You can obviously have a bad prior, but you can obviously fit a bad model. Discourse about what to include or exclude or account for within a given model takes place regardless of the method we are using to estimate uncertain parameters.

## Restrictions as priors

I haven't thought this through so it might be completely wrong (although I suppose it is often true I think things through and turn out to be wrong anyway), but I think it is possible to model any model restriction as a prior. In other words, if we imagined a space of every possible relationship between every possible variable, we only choose a subset of those parameters, and subset of functional forms for the relationship. In some models, like Gaussian process regression, we might think of estimation as including an infinite number of sub-models, but our choice of kernel is always one among many. Regardless, we already push the limits of feasible computation.

With this in mind, we leverage some kind of prior information when estimating our models. We set the parameters we don't include equal to 0. Our choice of a specific estimating procedure (or set of averaged models) relies upon a specific set of functional forms. Thus any model, even without specifying the likelihood or placing a prior distribution on our parameters, uses strong prior information to estimate models. Otherwise we simply can't identify any sort of relationships between anything.

This type of thinking may seem a touch philosophical, but it is important to remember that there are indeed models we try to estimate whose number of parameters exceed the number of data points. I guess I'm just arguing that choosing parameters to estimate is itself a type of structural information we are encoding in the model we estimate.

# Future thoughts

If sharp restrictions on models are equivalent to a strong prior (often a point mass), what happens when we weaken the information? If we have a structural model we want to estimate, but we are unsure about whether the model holds with certainty, are we better off encoding weight on the restriction as a proper prior and not a point-mass (e.g. sum-to-one or equal-to-0)? At that point the restricted model is a single model within a class of larger models, given a larger prior likelihood because of what we know from theory or previous measurements!

Might that lead us to understand where our models are breaking down and make better predictions? Is this what people mean when they talk about [weakly informative priors](https://www.mdpi.com/1099-4300/19/10/555/htm)? If we do this do we lose identification?

I don't know. But it would be interesting to check!
