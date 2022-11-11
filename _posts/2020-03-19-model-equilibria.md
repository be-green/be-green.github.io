---
layout: post
title: Model Equilibria
tags: stats, misc
---

Working in finance as a practitioner and then moving to a more academic role has been an interesting experience. In the first domain, it is widely accepted that signals associated with higher stock returns have some kind of half-life. At best, they are cyclical, coming into fashion at different times. In the academic sphere, some people treat these signals as movable (in the same way that practitioners do), but others hold that they represent fundamental and undiversifiable risks, and thus have an associated premium.

This problem is not unique to pricing equities, but applies more broadly to any model which people use to forecast (and whose forecasts they use to make decisions). Consider macroeconomic forecasts; the federal reserve makes forecasts about unemployment or inflation, and uses these to make policy decisions. 

We can imagine a world where the actions people take based on the model's forecasts do not change the behavior of the model in the future, and worlds where it does! For example, in the equity valuation case, if I trade based on the information in my model, it gets baked into the price. As others search for this information (or give me enough money to trade), we should expect the return to this information to be smaller and smaller. 

We could also imagine a world where the model actually affirms itself. Perhaps inflation expectations work in this way. I believe myself to have a certain amount of money, but if I expect future prices to drop, I hold onto that money. Without external intervention, this could lead to a drop in demand, lowering prices, and that could fuel my expectations further! This is not meant to be a scientific claim about how deflation happens, but instead maybe just some intuition for a self-affirming model.

Finally, there are models that have nothing to do with how their output is acted upon, and don't change in response to decisions. Imagine a neural network that identifies dogs in pictures. If I use this, perhaps I can find pictures of cute dogs faster, but the fact that I am finding cute dogs on the internet more efficiently does not fundamentally change the domain of what counts as a dog in a picture.

Let's formalize this. Imagine a model $M$, that maps some set of features $X$ to an output $Y$ (with or without error). So $M: X \to Y$. But then we have a layer after that, representing a decision based on that output. So $D$ is a mapping from $\widehat{Y}$, our forecast of the $Y$ variable from our model, to some outcome $O$.

In the case of stock returns, $Y$ is the future return of the stock. But a return is just a transformation of a price; returns are changes in log(price). Since our trading decisions impact the prices of the securities we trade, they also impact log(price), and thus returns! So as we trade, we impact the variable we are trying to model. Suppose our model was correct. Then $Y = M(X)$ before we trade. But after we trade, $Y = F(M(X), D(M(X))).$ Thus, if our model has some equilibrium state in its predictive power, it cannot be the "constant-domain" state, since our decisions actually change the domain of the model! If our model is a stochastic one, we would train or calibrate it for the future, including the way in which we impacted prices of the securities.
