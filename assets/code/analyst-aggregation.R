library(baggr) # bayesian meta-analysis models
library(quantmod) # get returns for things
library(data.table) # GOAT data package
library(ggplot2) # plotting

# let's number these nameless analysts, and give them
# each a standard error and average prediction
us_eq_forecasts <- data.table(
  analyst = 1:8,
  tau = c(0.08, 0.05, 0.02, -0.05,
               0.02, 0.03, -0.01, 0.09),
  se = c(0.05, 0.02, 0.1, 0.03,
              0.02, 0.1, 0.12, 0.02)
)


n = 1000

# mean prior
avg <- rnorm(n, 0.08, 0.2)

# se prior
se <- abs(rcauchy(n, 0, 0.2))

# draw from each prior draw to get forecast
forecast <- rnorm(n, mean = avg, sd = se)

# data for plotting
plot_data <- data.table(
  what = sort(rep(c("Mean", "SE", "Forecast"), 1000)),
  values = c(forecast, avg, se)
)

ggplot(plot_data, aes(x = values)) +
  facet_wrap(~what, scales = 'free_x') +
  geom_histogram() +
  xlab("") +
  ggtitle("Simulations from prior distributions",
          subtitle = "And simulations that represent observed data") +
  scale_y_continuous(trans = scales::log1p_trans())

# by default baggr uses normal(0, 0.81)
# we know the S&P has definitely NEVER been up 81%
# and on average it is up something like 7 or 8%
meta_fit <- baggr(us_eq_forecasts,
               prior_hypermean = normal(0.08, 0.2),
               prior_hypersd = cauchy(0, 0.05),
               control = list(adapt_delta = 0.9))

effect_plot(meta_fit) +
  theme_grey() +
  guides(fill = F)

