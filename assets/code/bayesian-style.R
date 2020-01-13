library(quantmod)
library(PerformanceAnalytics)
library(magrittr)
library(rstan)

options(mc.cores = 4)

get_price <- function(symbol) {

  sym_name <- gsub("[^A-Za-z]", "", symbol)
  sym <-
    getSymbols(symbol, auto.assign = F)

  colnames(sym) <- gsub(paste0(sym_name, "."),
                         "",colnames(sym), fixed = T)

  sym <- sym[,"Close"]
  colnames(sym) <- sym_name
  sym[]
}

get_prices <- function(symbols) {
  Reduce(merge, lapply(symbols, get_price))
}

# S&P 500, Russell 2k, 90 day treasuries,
# 5 year treasuries, 10 year treasuries, 30 year treasuries,
idx <- c("^GSPC","^RLV","^RLG", "^RUT", "^IRX",
         "^FVX", "^TNX", "^TYX")

# a couple random mutual funds
# AMCAP Fund A and Wasatch-Hoisington US Treasury Fund
fund <- c("AMCPX", "WHOSX")

calc_returns <- function(symbols) {
  get_prices(symbols) %>%
    .[complete.cases(.),] %>%
    Return.calculate(.)
}

idx_returns <- calc_returns(idx)

fund_returns <- calc_returns(fund)

# function for turning this into
# a list that our stan model can use
make_standata <- function(fundRet, idxRet) {
  # save which is which
  idxNames <- colnames(idxRet)
  fundNames <- colnames(fundRet)

  # only use periods where they both have returns
  joint_ret <- merge(idxRet, fundRet) %>%
    .[complete.cases(.),]

  list(
    N = nrow(joint_ret),
    K = length(idxNames),
    X = as.matrix(joint_ret[,idxNames]),
    R = as.vector(joint_ret[,fundNames])
  )
}

# compile model
style_reg <- stan_model("bayesian-style.stan")

# create data
# daily returns
amcap_style_data <-
  make_standata(fund_returns$AMCPX,
                idx_returns)

# weights should be the same
FactorAnalytics::style.fit(log1p(amcap_style_data$R),
                           log1p(amcap_style_data$X))

# MCMC sampling
amcap_fit <- sampling(style_reg, data = amcap_style_data)

rrep <- extract(amcap_fit, "R_rep")$R_rep

betas <- extract(amcap_fit, "beta")

betas <- data.table(betas$beta)
setnames(betas, colnames(betas), colnames(idx_returns))

ggplot(betas, aes(x = GSPC, y = RUA)) +
  geom_point()


# S&P 500, Russell 2k, 90 day treasuries,
# 5 year treasuries, 10 year treasuries, 30 year treasuries,
idx <- c("^RUT", "^IRX",
         "^FVX", "^TNX", "^TYX",
         "^RLV", "^RLG")

cor_idx_ret <- calc_returns(idx)


amcap_style_data <-
  make_standata(fund_returns$AMCPX,
                cor_idx_ret)

amcap_fit <- sampling(style_reg, data = amcap_style_data)

betas <- extract(amcap_fit, "beta")

betas <- data.table(betas$beta)
setnames(betas, colnames(betas), colnames(cor_idx_ret))

betas[,Index := .I]

melt(betas, "Index") %>%
  ggplot(aes(x = value)) +
  geom_density(fill = "#009ADF") +
  facet_wrap(~variable, scales = "free_y")

