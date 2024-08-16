#### LIBRAIRIES ####
library(readxl)
library(rcompanion)
library(MCMCglmm)
library(dplyr)
library(brms)
library(tidybayes)
library(ggplot2)


#### DATA ####

data <- read_excel("data.xlsx")
data$condition <- as.factor(data$condition)

hydration <- subset(data, thickness!="NA" & width_leaf!="NA" & eggs_per_area!="NA")
mortality_tot <- subset(data, THI_on_e!="NA")
post_hatching <- subset(data,stage=="early" & post_hatch!="0" & THI_on_e!="NA")
  

#### SURVIVAL CURVES ####

res.cox3 <- coxph(Surv(d_s_o, status_cl) ~ condition, data =  survive, model=TRUE) 
summary(res.cox3)

#### LEVEL OF HYDRATION ####

# weak prior for fixed (R) and random effects (G)
prior1 <- list(R = list(V = 1, nu = 0.002), G=list(G1=list(V=1, nu=0.002)))


# model
hydration.mcmc <- MCMCglmm(thickness ~ condition * d_s_o + width_leaf + THI_day + eggs_per_area,
                           random= ~clutch, family = "gaussian", prior = prior1, 
                           nitt = 1000000, burnin = 10000, thin = 100,data = as.data.frame(hydration),verbose = FALSE, pl = TRUE)


# diagnostic to check for autocorrelation
autocorr <- as.data.frame(autocorr(hydration.mcmc$Sol))
autocorr <- as.data.frame(t(autocorr))
which(autocorr$`Lag 100` > 0.1 |
        autocorr$`Lag 500` > 0.1 |
        autocorr$`Lag 1000` > 0.1|
        autocorr$`Lag 5000` > 0.1)

par(mar = c(2,2,2,2))


# diagnostic to check for sufficient mixing
geweke.plot(hydration.mcmc$Sol)
geweke.plot(hydration.mcmc$VCV)


# diagnostic for chain length
heidel.diag(hydration.mcmc$Sol)


# diagnostic for chain length and sampling
plot(hydration.mcmc$Sol)


# model results
summary(hydration.mcmc)


#### MORTALITY RATE ####

# Create new column and change 1 to 0.99999
mortality_tot$per_mort_end2 <- mortality_tot$per_mort_end
mortality_tot$per_mort_end2[mortality_tot$per_mort_end2 == 1] <- 0.99999

# Count the number of 0 in the data
mortality_tot %>% 
  count(per_mort_end2 == 0) %>% 
  mutate(prop = n / sum(n))

# 39.5% of the data are zeroes

# Create the formula
model_formula <- bf(
  # mean part
  per_mort_end2 ~ condition + THI_on_e + eggs_per_area_on_e + thickness_on_e,
  # precision part
  phi ~ condition + THI_on_e + eggs_per_area_on_e + thickness_on_e,
  # zero inflated part
  zi ~ condition + THI_on_e + eggs_per_area_on_e + thickness_on_e)

get_prior(
  model_formula,
  data = mortality_tot,
  family = zero_inflated_beta()
)

# With this function we can see what are the default priors and how to change them
# Everything with a class b (for beta coefficient in a regression model) has a flat prior
# We can narrow that down with a normal distribution

priors <- c(set_prior("student_t(3, 0, 2.5)", class = "Intercept"),
            set_prior("normal(0, 1)", class = "b"))

mortality.model <- brm(
  model_formula,
  data = mortality_tot,
  family = zero_inflated_beta(),
  prior = priors,
  init = 0,
  control = list(adapt_delta = 0.97,
                 max_treedepth = 12),
  chains = 4, iter = 2000, warmup = 1000,
  cores = 4,
  file = "model_beta_zi"
)

summary(mortality.model)

# Diagnostics
plot(model)
pairs(model)


#### DEVELOPMENTAL RATE ####

post_hatching$post_hatch <- 10*(post_hatching$post_hatch)

# weak prior for fixed (R) effect
prior2 <- list(R = list(V = 1, nu = 0.002))

development.mcmc <- MCMCglmm(post_hatch ~ condition + THI_on_e + eggs_per_area_on_e,
                             prior=prior2,family="poisson",nitt = 1000000, burnin = 10000, thin = 100,
                             data = as.data.frame(post_hatching),verbose = FALSE, pl = TRUE)


# model diagnostics
# diagnostic to check for autocorrelation
autocorr <- as.data.frame(autocorr(development.mcmc$Sol))
autocorr <- as.data.frame(t(autocorr))
which(autocorr$`Lag 100` > 0.1 |
        autocorr$`Lag 500` > 0.1 |
        autocorr$`Lag 1000` > 0.1|
        autocorr$`Lag 5000` > 0.1)

# diagnostic to check for sufficient mixing
geweke.plot(development.mcmc$Sol)
geweke.plot(development.mcmc$VCV)

# diagnostic for chain length
heidel.diag(development.mcmc$Sol)

# diagnostic for chain length and sampling
plot(development.mcmc$Sol)

# model results
summary(development.mcmc)


#### PLOTS ####

ggplot(data=hydration, aes(x=eggs_per_area, y=thickness)) +
  geom_point()+
  geom_smooth(method="lm")
