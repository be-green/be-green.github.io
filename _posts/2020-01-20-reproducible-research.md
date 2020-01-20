---
layout: post
title: Reproducible Research Tools and Good Data Practices
tags: pedagogy, R
---

I'm going to be running a set of classes focused on programming and working with data (think intro to data science, but really just on data and not modeling). In many ways, keeping track of and managing data and code are core functions of research that are largely ignored by traditional coursework. While the process of sharing data, code, papers, and presentations is a foundational aspect of collaboration and science, publishing on the topic is really not rewarded in the academic sphere. By contrast, in the corporate or data science world it is considered absolutely essential! If no one can replicate your model, how should we go about deploying it? For a large-scale implementation of a statistical model or piece of software, we need to understand everything from the data pipeline to the actual trained model, the update cycle, the associated machine's image, how it will scale, how it works with the user, and on and on.

But the considerations for a researcher are quite different. Fewer people use your tools, and the standard for how people interact with them is really not the same. For example, the most used tools in academic finance are packaged as data files and sent out in bulk. There is no streaming set of interactions that the model needs to cope with like you would find in a web interface for email autocomplete, for example. The model is not deployed with an API that users can ping at any time with online updates. If someone does use your software, we expect them to be sophisticated or persistent enough to figure out how to work with it.

At the same time, there are serious issues with the life of academic projects that can be addressed with tools we borrow from the corporate sphere. Projects often involve a series of research assistants who have limited familiarity with the tools at hand, and the individuals involved may graduate or move before a project is finished. Collaborators are often at different institutions without shared access to data. Authors change institutions altogether and want to bring their work with them. When collaborators do have shared access to data, often there are copious numbers of intermediate files that get generated through the project, and these go largely undocumented. 

This is a pretty specific set of challenges without as neat a set of tools as might exist at a Google or a Netflix. However, there are still really great (often free) resources for dealing with this stuff. In this post I'm going to try to think through what tools I might want to cover in the coming weeks, and a framework for thinking about their use in the research process.

# Basic tools

If a researcher is going to be empirical, it is critical for them to understand data and associated computation. Here are some things I think it is good to be familiar with as a researcher which no one teaches you in school:

* Basic command line for PC/Linux/Mac (directories, search paths, environment variables)
* Data concepts like key-value pairs, unique identifiers, joining datasets
* Basic SQL and principles of database design
* How to structure a project, tools for doing so
* Version control and unit testing
* Code documentation, introductory computer science concepts (e.g. functions, looping), how to read documentation
* Notebook tools like pandoc, markdown, knitr (for R users), etc.
* Build processes, whether light or heavy-weight (e.g. makefiles)

This may seem (either) like a) this is all really obvious and doesn't everyone do this or b) this all seems like stuff that isn't really very important to me. However, I would note that I have seen a large number of people saving almost everything to their documents folder without any real structure. Or a project with 100 file paths to keep track of, each of which is hard-coded into all of the scripts. Or massive excel files that are being used as data stores. I can't say I've never been guilty of this, but that's why I think it's important (even at an undergraduate level) to be arming people with this type of knowledge!

I guess I'm kind of rambling here, but I need to figure out how I am going to structure a  class on this topic, so let's start with a framework.

# A framework

A research project is relatively amorphous, with exploratory analysis sometimes creating subsequent data collection, methods changing as people get added on, a sudden scramble to address important feedback. The fact that projects take place over the course of years makes this even harder. The basic framework I'm proposing may need to be changed given your specific needs, but I think it encompasses a fair amount of projects. 

Let's start with principles:

1. Never touch your raw data directly

This means save it in a well-known format that is consistent across operating systems, like a .csv or .txt file. If you are feeling ambitious, consider using a lightweight SQL implementation like [sqlite](https://sqlite.org/index.html).

2. Assert and check expectations about your data

If you have a very long and complicated process for transforming your data that involves merging multiple datasets together, dropping certain observations, etc., then assert at each stage what the data should look like. For example, which column(s) do you expect to uniquely identify the samples? Once you know that, you can write tests which run every time you run your build process. As you make changes or add additional filters, this will catch mistakes before they cascade too long.

3. Have a process that builds to the analysis from scratch

Once you have your data in a format that you want to begin your analysis, write that build process down in the order that it happens. At the simplest end, you could have a script which sources your build scripts and tests in order, outputting the processed files you need for your analysis.

4. Work with working directories

Never hard-code filepaths. Ever.

5. Visual checks are always faster

Have plots that regularly visualize your raw data at intermediate steps to help diagnose problems. I particularly like histograms for this purpose, but this is likely context specific.

6. Use real version control

Whether this is git or perforce or SVN or whatever, version control your project! No, this does not mean saving model_v2.py.

# Research as a pipeline

Empirical research is a series of transformations applied to data and summarized in outputs, embedded within a story. The number of inputs and outputs are highly variable, with a potentially infinite number of both. The process of "doing research" is characterized by identifying and collecting additional inputs, transforming them once or several times, and then combining those transformed inputs into static outputs, like presentations or papers. Reproducibility, in this context, is the ability for a person to take your inputs, apply the same transformations to those inputs, and get the same outputs (often within some margin of error).

The biggest argument for a reproducible research pipeline is the fallibility of your own memory. I guarentee that you will not remember which version of which model was the right one that generated a given figure in that paper in this version that we presented at that conference three to six months after it happened. It is quite common to be pulled in many directions at once, only coming back to a project as time or interest allows. In this sense, a reproducible research pipeline allows you to trace the point of origin for a dataset all the way to the figure it creates, in the document that uses that figure.

This is quite a formidable problem, and one which is not entirely solved. There are nice tools which help to address these concerns, some of which are discussed earlier, but more importantly this metaphor gives us an extensible structure for working with and storing our data. 

## Normative implications

Data storage and organization:

We should have a place for our "raw" data (e.g. un-transformed inputs, however we recieved them initially). What qualifies as "raw" data probably depends on the project, but let us say for our purposes that it is data that _you_ or your team have not edited, manipulated, or touched. This should be kept separate from the transformation pipeline so that others can generate our work given the full project.

We should have a place for our "transformed" data, either at an intermediate or fully processed step. This is to say that some data is transformed only to be transformed again! To not be burdensome, we will call all such transformations "intermediate," but ideally we would have a way of tracking the order and type of these transformations. If called for, these transformative intermediate steps might be broken out with more informative names.

We should have a place of storing our finally "transformed" data that is included in our model, should our research include a model. In some cases the research may simply be the data, at which point this advice should be ignored. I'll consider a model anything which places structure around data to fit within a story. In this sense, our model could be code that plots one variable against another. A model could be a linear regression.

Code tracking, organization, and style:

We should have a place for our code which transforms our data. Code in this case could be a broad term, encompassing anything to do with computation enacted upon the data. I would recommend avoiding excel though, for other reasons. But in principle, the same workflow could apply.

We should have a place for our code that tests whether those transformations worked correctly. This code should be run regularly, and notify the user when there are errors or other issues.

We should have a place for our code that takes our processed data and enacts our models upon that data in order to create outputs. The code should automatically save those outputs to a location.

Code which is used repeatedly across scripts (e.g. copied and pasted) should be broken out into separate modules so that it can be consistently relied upon. If it is highly critical code, it should also have associated tests which run with the project.

Outputs:

There should be a folder that contains our outputs. If we have different kinds of output files, like tables or charts, then we should put them in a folder for that. If we have multiple types of outputs (for example, two papers that use the same dataset), we should have a way of generating each separately. If possible, we should also have a place for the code which generates the "final" output, like the paper or presentation we are going to submit or present.

Documentation:

Document to the extent it is useful. Try to make things easy to understand, but also recognize that others may still find confusing what is clear to you. At the very least, there should be a single file which demonstrates which files do what, what data is contained in the various files, and so on. This is excruciatingly painful, but can be very important.

File structure:

Each project should be in a single directory. If you have multiple collaborators, they should accomplish this by working with git. If you have large raw datasets that cannot be copied across machines (e.g. with git LFS), you should figure out a server that can host the data where collaborators can access it.

Multiple projects:

Using the same data:
At the point where there are multiple research projects built upon the same raw data (or which rely in part on that data), we should consider organizing that data into some kind of bucket accessible via query or API. This is to say that the "head" of the project should be self-contained, but in order to avoid copying, we should consider placing the raw data sources in some sort of separate storage. The rest of this, then, still applies.

Using the same code:
If similar or identical code is used across multiple projects, the code should be separated into its own self-contained unit that may be installed as necessary in the build process for each project. This helps to ensure proper testing and documentation, and may result in a separate contribution from the original research project should the code be useful enough to others.

## Teaching the Pipeline

I'm still a little stuck on how to teach tools within this type of framework. Obviously not everyone is going to adopt this, and I don't even follow this advice to the extent I should. At the same time, it might provide a reason for learning specific research tools. And some of the tools and practices will still be useful in smaller bits and pieces. Here's how I'm thinking of starting.

First class: Hadley Wickham's "tidy data" concept, visualization of data with ggplot2

Second class: Rmarkdown and notebooks more broadly

Third class: Data structures, binary search, working with keys, speed w/ data.table

Fourth class: Version control with git, unit testing, catching mistakes

Fifth class: Bits and pieces (project organization, command line, build files, computer paths, environment variables)

I think that there are a few topics that I was asked to touch on separately from these that are unrelated to reproducible research. So I've got to fit in web scraping, APIs, XML, JSON (maybe some of these are in data structures?). I don't know.

I want to make all of this relatively interactive, and as I get teaching materials I will post them. I'm likely going to be doing the whole thing in a set of notebook-style formats (either Jupyter or RMarkdown), with relevant notes written up separately.

