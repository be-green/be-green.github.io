---
layout: post
title: Automatic queries with the WRDS package
tags: finance, R
---

I recently built a teeny R package for handling data from Wharton Research Data Services' back-end database to make it easier to work with.

# The problem

I've been working on some projects that require daily or monthly updates with data from [Wharton Research Data Services](https://wrds-www.wharton.upenn.edu/). In finance, WRDS is a ubiquitous data provider for academic research; it has mutual fund information, security data from CRSP, firm information from Compustat, and a whole bunch of other stuff.

However, the primary way they suggest you automatically pull data is through SAS Studio, which is essentially a SAS installation on their server. If you want to batch stuff, you have to kick off jobs on their server by saving a SAS script locally to their server, ssh-ing in on a scheduled basis, and kicking it off with qsas (praying that your timing doesn't break). There might be smarter ways to do this, but they are probably all a pain. That is currently what I do to generate the visualizations for the [website examining the impact of supply-side COVID disruptions on financial markets](https://www.thecovidfactor.org/). But that has a lot of issues.

- You have to use SAS. 
- There is a space limit on your user directory.
- You can't really work with it interactively.
- You have to log into another machine to use the data.

This has already broken (if you go on the website, as of this posting you can see that it last updated in September of last year). 

So what about the alternative? If you want to use the PostgreSQL backend via R without the package I made, it might look like this:

```
# connect to WRDS and query some stuff

user <- "uid"
pass <- "pass"
con <- DBI::dbConnect(odbc::odbc(), 
        Driver = "PostgreSQL ANSI(x64)"
        Server = "wrds-pgdata.wharton.upenn.edu", 
        Database = "wrds", UID = user, PWD = pass, Port = 9737, 
        sslmode = "require", ...)>

query <- "SELECT *
FROM crsp.monthly_nav mn
INNER JOIN crsp.fund_hdr fh
ON mn.crsp_fundno = fh.crsp_fundno
WHERE mn.caldt > CAST('2019-01-01' AS DATE) 
AND fh.ticker in ('PIMIX', 'ABNDX')"

data <- DBI::dbGetQuery(query)
```

That has it's own problems! 

- Hardcoded user id and password
- You have to understand stuff about databases
- You have to know sql
- Long sql queries as strings are really annoying

Instead this becomes

```
library(wrds)
library(dplyr)
libray(dbplyr)

# funds I want, previously had to be in SQL query
tickers <- c("ABNDX", "PIMIX")

# connect to wrds
con <- connect_to_wrds()

# create a dplyr tbl which acts as tibble after running collect
monthly_nav <- tbl(con, in_schema("crsp", "monthly_nav"))
fund_header <- tbl(con, in_schema("crsp", "fund_hdr"))

# let's do what the SQL did implicitly
my_funds <- inner_join(monthly_nav, 
                       fund_header, 
                       by  = "crsp_fundno") %>%
  filter(caldt > as.Date("2019-01-01") & ticker %in% c("PIMIX","ABNDX"))
```

which is much more familiar to R users who are already working in the tidyverse, and doesn't require any SQL knowledge! It'll also run on someone else's machine without having to manager odbc connection names (if you haven't encountered this stuff just be grateful).

# What it does & how to use it

First things first, if you want to install it and play around, just run 

```
# check if we already have devtools
if(!require(devtools, quietly = T)){
    install.packages("devtools")
}
# install the package
devtools::install_github("be-green/wrds")
```

You'll also need to install postgres drivers from here: https://odbc.postgresql.org/

So what does the package do? I'd say maybe 3 important things.

1. It saves your username and password into local environment variables so that you don't accidentally commit that stuff to github/bitbucket/gitlab
1. Once you are set up, it handles all of the necessary connection specifics, and generates a database connection via the `odbc` package
1. It has some rudimentary search facilities that let you access the wrds help website, search through schemas, and load full schemas into your R session for exploratory purposes.

# Examples

What would this be without some examples? First set up your username and password:

## Setup and connecting
```
# Set up username and password (only need to do once)

set_wrds_user("uid")
set_wrds_pass("pass")
```

Then we are ready to connect! This is a one-time setup for each user, so that the scripts you commit to a git repo do not need to include your information. Any user with the same database access (or WRDS subscription) as you will be able to run your code as is, without any additional setup, should they have the package installed.

The basic connection function is 

```
con <- connect_to_wrds()
```

This is a `DBI` style connection, just like any other typical database. There are some weirdly specific settings for the WRDS server though, and this sort of hides those annoying bits behind a function. For example, who (besides me) is really going to learn that the server name is `wrds-pgdata.wharton.upenn.edu`, you need port 9737, and you need to require ssl to connect? No one is who.

From there you can work with it like any normal SQL database, via all of the nice DBI functions. I'm not going to talk too much about those because there are [nice guides from Rstudio](https://db.rstudio.com/dbi/) that are better than what I would make. But as an example, you can run

```
DBI::dbGetQuery(con, "select * from monthly_nav limit 10")
```

and it'll work.

## Searching through the WRDS database

What I quickly realized is that there are an INSANE number of tables, and all of them are returned as potential options to query, even though a user can't actually access them. So I made some functions for searching through the various schemas and tables.

```
# list all database schemas available on back end of WRDS
list_schemas(con)

# list all schemas matching the phrase "crsp"
list_schemas(con, "crsp")
```

There's also a top 10 * helper function called `peek` which can be useful. 

```
# get top 10 rows of the monthly nav table
peek(con, "monthly_nav")
```

There are also functions for writing your own queries in case you don't want to deal with loading the DBI package yourself. 

```
# this is basically just calling DBI::dbGetQuery
query(con, "select * from monthly_nav limit 10")

# this read the contents of the file and passes them as a query
query(con, "monthly_nav_top_10.sql")
```

Because I am possibly the laziest person in existence, I also wrote a function which automatically brings up the WRDS help pages when you get confused about stuff. If you run

```
search_wrds("crsp mutual fund data")
```

It will launch a browser window for documentation matching CRSP mutual fund data.

## Working with dplyr/dbplyr

Here's the actual fun stuff! If you use dplyr for your analysis already, then you can just immediate transition your code to working with the sql tables, only collecting into memory when you need it! Here's an example with the monthly nav table:

```
# get mutual fund monthly NAVs
library(dplyr)
library(dbplyr)
library(wrds)

con <- connect_to_wrds()

monthly_nav <- tbl(con, in_schema("crsp", "monthly_nav"))

# Grab NAVs from the last 2 years
recent_navs <- monthly_nav %>% 
  filter(caldt > "2019-01-01")
  
# bring into R's memory from database
recent_navs <- collect(recent_navs)
```

There is actually nothing in memory except the connection, just a plan to evaluate until you hit collect. You can also perform joins this way, keeping them out of the memory of your local machine.

# Conclusion

I guess that's it. If you end up using the package or have questions please reach out!