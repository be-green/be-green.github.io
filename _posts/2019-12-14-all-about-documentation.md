---
layout: post
title: Finding (and Using) Help
tags: programming, R, beginning
---

One of the things I see beginners of any programming language struggling with most is the seemingly endless stream of knowledge that they need to have in order to code properly. Documentation is seemingly useless and far too technical to follow, especially if you just learned what a variable is. And error messages like `object of type closure is not subsettable` are beyond cryptic. 

## Everybody Googles

First, you need to remember that literally every single developer searches the internet for answer to problems that they face on a daily basis. Every single one. If we added this question to the census I would not be surprised to find out that literally 100% of people who currently develop software have searched for answers on the internet. I would bet that most (if not all of them) have simply pasted the solution into their code without understanding what it does at all!

Obviously in a production software setting this is not ideal, but for a quick workaround it can be great. I am willing to admit that my regex skills are no match for [this guy's](https://stackoverflow.com/a/15504877/7158451) who provided this nice regex for finding dates in strings:

```
^(?:(?:31(\/|-|\.)(?:0?[13578]|1[02]))\1|(?:(?:29|30)(\/|-|\.)(?:0?[13-9]|1[0-2])\2))(?:(?:1[6-9]|[2-9]\d)?\d{2})$|^(?:29(\/|-|\.)0?2\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))$|^(?:0?[1-9]|1\d|2[0-8])(\/|-|\.)(?:(?:0?[1-9])|(?:1[0-2]))\4(?:(?:1[6-9]|[2-9]\d)?\d{2})$
```

Do I understand it? No! Could I understand it given enough time? Probably? Do I need to? Depends on the context! So don't feel bad about it.

## Searching for help on the internet

There are many places to find programming help on the internet, but by far the most important is [stackoverflow](stackoverflow.org), an organization dedicated to answering questions about programming. I guarentee that someone has had your problem before, and if it isn't really, really strange then it's going to show up there. 

However, it's important to know how to search for this stuff and what to look for in an answer. I would first suggest (even if you don't understand it) copying the error or warning message and searching for that phrase directly. One thing that is good to get the hang of is which parts of the error are specific to your problem and which are general parts of the error message that you can search for. For example, if there is a specific variable or function named in the error message, that's likely something that is automatically pasted into the message based on your input, and so someone elses' question isn't going to have it.

As an example, if I'm working in an R session and I run

```
library(test)
```

The output is something like 

```
Error in library(test) : there is no package called ‘test’
```

Now this is a simple enough phrase that searching for this directly gets some results, but noticing that `test` is the thing you plugged in to the function should clue you in to the idea that this is an error message that doesn't say test every time. So taking that part out will likely be helpful.

## Using official documentation

The second place you should look is official language or system documentation. The first problem is how to actually _get_ the documentation. Often languages have built-in search functionality via some kind of `?` or `help` command. If I wanted help in R for a function that can help to profile code I might run

```
?proc.time
```

(Sidenote: in real life use the [microbenchmark](https://cran.r-project.org/web/packages/microbenchmark/microbenchmark.pdf) package for doing stuff like this)

The main problem with understanding documentation for beginners is that it is written by software developers. This is kind of like reading statistics papers in a field that you've never taken a class in (or maybe just any statistics paper). There's all these matrices and you sit down and try to copy the math into your notebook to follow it but then you hit a section and have to go **HOW ARE THOSE THE SAME THING**? How did that happen?

So keep in mind that this is going to be most useful to you once you have a basic grasp on the language. You'll get the hang of it. Let's work an example of this, here is the documentation that comes from running `?MASS::mvrnorm`.

```
mvrnorm {MASS}	R Documentation
Simulate from a Multivariate Normal Distribution

Description
Produces one or more samples from the specified multivariate normal distribution.

Usage
mvrnorm(n = 1, mu, Sigma, tol = 1e-6, empirical = FALSE, EISPACK = FALSE)

Arguments
n - the number of samples required.
mu - a vector giving the means of the variables.
Sigma - a positive-definite symmetric matrix specifying the covariance matrix of the variables.
tol - tolerance (relative to largest variance) for numerical lack of positive-definiteness in Sigma.
empirical - logical. If true, mu and Sigma specify the empirical not population mean and covariance matrix.
EISPACK	- logical: values other than FALSE are an error.

Details 
The matrix decomposition is done via eigen; although a Choleski decomposition might be faster, the eigendecomposition is stabler.

Value
If n = 1 a vector of the same length as mu, otherwise an n by length(mu) matrix with one sample in each row.

Side Effects
Causes creation of the dataset .Random.seed if it does not already exist, otherwise its value is updated.

References
B. D. Ripley (1987) Stochastic Simulation. Wiley. Page 98.

See Also
rnorm

Examples
Sigma <- matrix(c(10,3,3,2),2,2)
Sigma
var(mvrnorm(n = 1000, rep(0, 2), Sigma))
var(mvrnorm(n = 1000, rep(0, 2), Sigma, empirical = TRUE))
[Package MASS version 7.3-51.4 Index]
```

Most R documentation looks like this, and honestly Stata's and Matlab's docs will look very similar. Here are the things that should jump out to you:

### Usage

The usage section tells you what the function looks like when you run it. Most of the time when I see people making mistakes (a cry in the distance, "the code you gave me doesn't run") it's a syntax error. Usage tells you what the syntax is supposed to be, and what the defaults are for the function. 

The first thing that we can take away from reading this is that `mvrnorm` takes as inputs the arguments listed in the _Arguments_ section, and returns a random number simulated from the multivariate normal distribution. What is subtler to someone who hasn't worked with software is exactly what the user is required to specify and what they aren't. In this case, `n` has a default argument, which we can glean from the fact that `n=1` in the function. However, `Sigma` and `mu` do not have default arguments, so if you don't specify them you will get an error! This is a _very_ important distinction.

The second thing we can take away is the _order_ of the arguments. While it is clear to people who have done this for a while, if you are just starting out, how do you know what to specify where? In R you can either specify arguments by name (e.g. `mvrnorm(n = 1, Sigma = mat, mu = c(0.01,0.02))` where `mat` is some covariance matrix you have previously specified) or by the order of the arguments (e.g. `mvrnorm(1, mat, c(0.01,0.02)`)). The first will **always** trump the second. If you give it a name, it will ignore the order.

Sometimes you see `...` displayed as an argument. That essentially opens the field up to any set of named arguments you want to pass along to the function. Usually this is either described in detail in the documentation or just there for compatibility reasons, but in either case you should generally specify names for your arguments when you see that a function has `...` as one of its arguments.

### Arguments

The arguments section describes what you can change about the function's arguments (often called parameters). This will tell you what each of those things is supposed to control. So now that we understand the structure of the function, we can see that `n` controls the number of samples. `Sigma` controls the covariance for the joint distribution of the random variables you are sampling. `mu` specifies the mean of those variables. 

Importantly it also tells you the restrictions on those parameters. If you, for example, pass a string instead of a number into the `n` argument, you will get an error. This is because `n` is meant to be a number. If you pass a matrix that is not positive definite into your `Sigma` parameter, you'll also run into an error. These are all things we can glean from the documentation.

### Details, See-Also, Examples

The details section is sometimes important, usually it contains technical information that is too long to list in the brief argument description sections. "See Also" will link related functions. The most important part, though, is examples. If you are confused about how to work with a function, copy an example and modify it.

## Finding what to find

Often I find that people will install a package but then don't really know how to find what it has available. There are a couple ways of doing this. If you open up the documentation (let's say via `?MASS::mvrnorm`), you can scroll down to the bottom where there is a link that says _index_. Clicking on that will show you all the documentation for the functions and values that are exported by the package.

Second you can look at the official CRAN webpage for the package. That will have a link to the full documentation in one PDF document that you can search through.
