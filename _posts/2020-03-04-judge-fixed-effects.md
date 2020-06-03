---
layout: post
title: Nudging Judges and Instrumental Variables
tags: economics, reproducibility
---

The idea that judges have wide latitude in deciding how criminal cases move forward is fairly uncontroversial. I also think that some judges are especially harsh on some times of crime, while others care less. Since I am relatively in the dark about the workings of the U.S. criminal justice system, someone could convince me fairly easily that judges are harder on crime during election years, in places where judges are elected.

There is a well-known strategy for inducing quasi-random assignment of sentencing on defendents. Since judges vary in how mean they are (some like longer sentences and more convictions) and are assigned randomly, this has a random-experiment-like flavor that economists use to evaluate the impact of longer sentencing on some outcome variable. Maybe this is how likely someone is to commit a crime again, or earnings after release.

 One of the important assumptions in this model is that judges are fairly stable in terms of their type. Judges don't vary how they weight different types of crimes or for different types of defendants. This is usually the biggest problem this strategy needs to grapple with, since there is fairly strong evidence that judges treat defendants of different races and socioeconomic statuses differently.

On average, though, I think it's a pretty nice model. Not perfect, but certainly an interesting way to look at things.

# Nudges for Judges

However, there is another strand in the literature where judges are, in fact, the _opposite_ of a person with any kind of stability in their judgements. A recent paper in the [AEJ: Applied Economics](https://www.aeaweb.org/articles?id=10.1257/app.20170223) writes that "a 10°F degree increase in case-day temperature reduces decisions favorable to the applicant by 6.55 percent. This is despite judgements being made indoors, "protected" by climate control."

[Another paper](https://www.aeaweb.org/articles?id=10.1257/app.20160390) (in the same journal, 2018) argues that judges are angrier when their football team loses on Saturdays and Mondays, and give longer sentences.

I am quite skeptical of the findings in both of these papers, but more on that in a second. First, let's take both at face value. If temperature has a monotonic effect on how happy judges are (despite there being heat and air conditioning almost everywhere in the United States), perhaps it would be in the best interest of criminals to commit crimes such that their trials are timed for warmer months. Or, to commit crimes during years where a local college has a good football team. 

And what about the interactions? If the football team is good, on average, and it plays in the winter (which is cold), maybe we should be controlling for temperature when evaluating the impact of football. Or maybe, vice versa, judges are happier during football season in aggregate, and this leads them to convict less in the winter!

What I do like about these papers is that they have really cool datasets. The temperature one merged in more than 200 thousand court cases with hourly temperature records! Pretty cool!

In general, I am quite skeptical of the findings. For one thing, it reminds me of the [piranha problem](https://statmodeling.stat.columbia.edu/2017/12/15/piranha-problem-social-psychology-behavioral-economics-button-pushing-model-science-eats/); it just doesn't seem likely that there are this many first-order effects because they would cancel each other out. More importantly, aren't these two strands of the literature in fundamental tension with each other? Judges can't both be a consistent determinant of sentencing length and also impacted by outside temperatures while in a climate-controlled room. It just doesn't seem like we can hold both to be true at the same time.