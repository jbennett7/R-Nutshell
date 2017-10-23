#!/usr/bin/env R --no-save
# Part Five: Statistics with R
# Chapter 16: Analyzing Data

# Summary Statistics: pages 351 - 353
# mean, min and max of a data set
library(nutshell)
data(dow30)
mean(dow30$Open)
min(dow30$Open)
max(dow30$Open)

# For each of these function, the argument na.rm specifies how NA values are treated.
# By default, if any value in the vector is NA, then the value NA is returned.
# Specifying na.rm=TRUE ignores these missing values.
mean(c(1, 2, 3, 4, 5, NA))
mean(c(1, 2, 3, 4, 5, NA), na.rm=TRUE)

# Outliers can be removed from a data set with the trim function and specifying
# the fraction of observations to filter.
mean(c(-1, 0:100, 2000))
mean(c(-1, 0:100, 2000), trim=0.1)

# To calculate the minimum and maximum at the same time, use the range function.
range(dow30$Open)

# Another useful function is quantile. This function can be used to return the values
# at different percentiles.
quantile(dow30$Open, probs=c(0, 0.25, 0.5, 0.75, 1.0))

# You can return this specific set of values with the fivenum function.
fivenum(dow30$Open)

# To return the interquartile range (the difference between the 25th and 75th percentile
# values), use the function IQR.
IQR(dow30$Open)

# Each of these functions are useful on their own but can also be used with apply, tapply,
# or another aggregation function to calculate statistics for a data frame or subsets of a
# data frame.

# The most convenient function for looking at summary information is summary. It is a 
# generic function that works on data frames, matrices, tables, factors, and other
# objects. The summary function presents information about each variable in the data
# frame. For numeric values, it shows the minimum, first quartile, median, mean, third
# quartile, and maximum values. For factors, summary shows the count of the most frequent
# values. (Less frequent values are grouped into an "Other" category.) Summary doesn't
# show meaningful information for character values.
summary(dow30)

# A popular alternative to summary is the str function. The str function displays the
# structure of an object.
str(dow30)

# A useful text-based alternative to the hist function is the stem function which will

# display the distribution of a numeric vector.
data(field.goals)
stem(subset(field.goals, play.type=="FG no")$yards)

# Correlation and Covariance: pages 354 - 356
# Very often when analyzing data, you want to know if two variables are correlated.
# Informally, correlation answers the question, "When we increase (or decrease) x,
# does y increase (or decrease), and by how much?" Correlation measures range from
# -1 to 1. A value of 1 means the two variables are positively related, 0 means the
# two variables are not related at all, and -1 means the two variables are negatively
# related.
#
# The most commonly used correlation measurement is the Pearson correlation statistic
# (it's the formula behind the CORREL function in Excel). The Pearson correlation is
# rooted in the properties of the normal distribution and  works best with normally
# distributed data.
#
# An alternative correlation function is the Spearman correlation statistic. Spearman
# correlation is a nonparametric statistic and doesn't make any assumptions aout the
# underlying distribution.
#
# Another measurement of how well two random variables are related is Kendall's tau.
# Kendall's tau formula works by compairng rankings of values in two random variables,
# not by comparing the values themselves.
#
# To compute correlations in R, you can use the function cor. This function can be
# used to compute each of the correlation measures described.
#        cor(x, y = NULL, use = "everything",
#            method = c("pearson", "kendall", "spearman"))
# You can compute correlations on two vectors (assigned to arguments x and y), a data
# frame (assigned to x with y=NULL), or a matrix (assigned to x with y=NULL). If you
# specify a matrix or a data frame, then cor will compute the correlation between each
# pair of variables and return a matrix of results.
# 
# The method argument specifies the correlation calculation. The use argument specifies
# how the function should treat NA values. If you want an error raised when values are
# NA, choose use="all.obs". If you would like the result to be NA when an element is NA,
# choose use="everything". To omit cases where values are NA, choose use="complete.obs".
# To omit cases where values are NA, but return NA if all values are NA, specify
# use="na.or.complete". Finally, to omit pairs where at least one value is NA, choose
# use="pairwise.complete.obs".
data(births2006.smpl)
births2006.cln <- births2006.smpl[
  !is.na(births2006.smpl$WTGAIN) &
  !is.na(births2006.smpl$DBWT) &
  births2006.smpl$DPLURAL == "1 Single" &
  births2006.smpl$ESTGEST>35,]
#smoothScatter(births2006.cln$WTGAIN, births2006.cln$DBWT)
cor(births2006.cln$WTGAIN, births2006.cln$DBWT)
cor(births2006.cln$WTGAIN, births2006.cln$DBWT, method="spearman")

# A closely related idea is covariance, covariance is the numerator of the Pearson
# correlation formula. You can compute covariance in R using the cov function, which
# accepts the same arguments as cor.
#        cov(x, y = NULL, use = "everything",
#            method = c("pearson", "kendall", "spearman"))
# If you have computed a covariance matrix, you can use the R function cov2cor to
# compute the correlation matrix.

# You can also compute weighted covariance measurements using the cov.wt formula.
#        cov(x, wt = rep(1/nrow(x), nrow(x)), cor = FALSE, center = TRUE,
#            method = c('unbiased", "ML"))

# Principal Components Analysis: pages 357 - 360
# Another technique for analyzing data is principal components analysis. Principal 
# components analysis breaks a set of (possibly correlated) variables into a set of
# uncorrelated variables.
#
# In R, principal components analysis is available through the function prcomp in the
# stats package.
#        prcomp(formula, data = NULL, subset, na.action, ...)
#        prcomp(x, retx = TRUE, center = TRUE, scale. = FALSE, tot = NULL, ...)
library(RSQLite)
drv <- dbDriver("SQLite")
con <- dbConnect(drv,
  dbname=system.file("extdata","bb.db",package="nutshell"))
team.batting.00to08 <- dbGetQuery(con,
  paste(
    'SELECT teamID, yearID, R as runs, ',
  '   H-"2B"-"3B"-HR as singles, ',
  '   "2B" as doubles, "3B" as triples, HR as homeruns, ',
  '   BB as walks, SB as stolenbases, CS as caughtstealing, ',
  '  AB as atbats ',
  '  FROM Teams ',
  '  WHERE yearID between 2000 and 2008'))
