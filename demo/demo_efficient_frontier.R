#' ---
#' title: "Efficient Frontier Demo"
#' date: "7/17/2014"
#' ---

#' This script demonstrates how to compute and plot the efficient frontier
#' given different constraints and objectives.

#' Efficient frontiers can be plotted two ways
#' 1. Run optimize.portfolio with trace=TRUE and then chart that object.
#' 2. create an efficient frontier and then chart that object.

#' Load required packages
library(PortfolioAnalytics)
library(DEoptim)
library(ROI)
require(ROI.plugin.quadprog)
require(ROI.plugin.glpk)

#' Load the data and change the column names for better legends in plotting.
data(edhec)
R <- edhec[, 1:5]
colnames(R) <- c("CA", "CTAG", "DS", "EM", "EQM")
funds <- colnames(R)

#' Set up the initial portfolio object with some basic constraints.
init <- portfolio.spec(assets=funds)
init <- add.constraint(portfolio=init, type="full_investment")
init <- add.constraint(portfolio=init, type="box", min=0.15, max=0.45)
init <- add.constraint(portfolio=init, type="group",
                       groups=list(c(1, 3),
                                   c(2, 4, 5)),
                       group_min=0.05,
                       group_max=0.7)

#' Add objectives for mean-ES (Expected Shortfall) portfolio.
meanetl.portf <- add.objective(portfolio=init, type="risk", name="ES")
meanetl.portf <- add.objective(portfolio=meanetl.portf, type="return", name="mean")

#' Add objectives for mean-variance portfolio.
meanvar.portf <- add.objective(portfolio=init, type="risk", name="var", risk_aversion=10)
meanvar.portf <- add.objective(portfolio=meanvar.portf, type="return", name="mean")

#' Compute the mean-variance efficient frontier.
meanvar.ef <- create.EfficientFrontier(R=R, portfolio=init, type="mean-StdDev")
meanvar.ef
summary(meanvar.ef, digits=2)
meanvar.ef$frontier

#' The RAR.text argument can be used for the risk-adjusted-return name on the 
#' legend, by default it is 'Modified Sharpe Ratio'.
chart.EfficientFrontier(meanvar.ef, match.col="StdDev", type="l", 
                        RAR.text="Sharpe Ratio", pch=4)

#' The tangency portfolio and line are plotted by default, these can be 
#' ommitted by setting rf=NULL.
chart.EfficientFrontier(meanvar.ef, match.col="StdDev", type="b", rf=NULL)

#' The tangency line can be omitted with tangent.line=FALSE. The tangent 
#' portfolio, risk-free rate and Sharpe Ratio are still included in the plot.
chart.EfficientFrontier(meanvar.ef, match.col="StdDev", type="l", tangent.line=FALSE)

#' The assets can be omitted with chart.assets=FALSE.
chart.EfficientFrontier(meanvar.ef, match.col="StdDev", type="l", 
                        tangent.line=FALSE, chart.assets=FALSE)

#' Just the names of the assets can be omitted with labels.assets=FALSE and the 
#' plotting character can be changed with pch.assets.
chart.EfficientFrontier(meanvar.ef, match.col="StdDev", type="l", 
                        tangent.line=FALSE, labels.assets=FALSE, pch.assets=1)

#' Chart the asset weights along the efficient frontier.
chart.EF.Weights(meanvar.ef, colorset=bluemono, match.col="StdDev")

#' Chart the group weights along the efficient frontier.
chart.EF.Weights(meanvar.ef, colorset=bluemono, by.groups=TRUE, match.col="StdDev")

#' The labels for Mean, Weight, and StdDev can be increased or decreased with
#' the cex.lab argument. The default is cex.lab=0.8.
chart.EF.Weights(meanvar.ef, colorset=bluemono, match.col="StdDev", main="", cex.lab=1)

#' If you have a lot of assets and they don't fit with the default legend, you
#' can set legend.loc=NULL and customize the plot.
par(mar=c(8, 4, 4, 2)+0.1, xpd=TRUE)
chart.EF.Weights(meanvar.ef, colorset=bluemono, match.col="StdDev", legend.loc=NULL)
legend("bottom", legend=colnames(R), inset=-1, fill=bluemono, bty="n", ncol=3, cex=0.8)
par(mar=c(5, 4, 4, 2)+0.1, xpd=FALSE)

#' Run optimize.portfolio and chart the efficient frontier of the optimal
#' portfolio object.
opt_meanvar <- optimize.portfolio(R=R, portfolio=meanvar.portf, 
                                  optimize_method="ROI", trace=TRUE)

#' The efficient frontier is created from the 'opt_meanvar' object by getting.
#' The portfolio and returns objects and then passing those to create.EfficientFrontier.
chart.EfficientFrontier(opt_meanvar, match.col="StdDev", n.portfolios=25, type="l")

#' Rerun the optimization with a new risk aversion parameter to change where 
#' the portfolio is along the efficient frontier. The 'optimal' portfolio 
#' plotted on the efficient frontier is the optimal portfolio returned by 
#' optimize.portfolio.
meanvar.portf$objectives[[2]]$risk_aversion=0.25
opt_meanvar <- optimize.portfolio(R=R, portfolio=meanvar.portf, optimize_method="ROI", trace=TRUE)
chart.EfficientFrontier(opt_meanvar, match.col="StdDev", n.portfolios=25, type="l")

#' The weights along the efficient frontier can be plotted by passing in the
#' optimize.portfolio output object.
chart.EF.Weights(opt_meanvar, match.col="StdDev")

chart.EF.Weights(opt_meanvar, match.col="StdDev", by.groups=TRUE)

#' Extract the efficient frontier and then plot it.
#' Note that if you want to do multiple charts of the efficient frontier from
#' the optimize.portfolio object, it is best to extractEfficientFrontier as 
#' shown below.
ef <- extractEfficientFrontier(object=opt_meanvar, match.col="StdDev", n.portfolios=15)
ef
summary(ef, digits=5)
chart.EF.Weights(ef, match.col="StdDev", colorset=bluemono)
chart.EF.Weights(ef, match.col="StdDev", colorset=bluemono, by.groups=TRUE)

#' Compute the mean-ES efficient frontier.
meanetl.ef <- create.EfficientFrontier(R=R, portfolio=init, type="mean-ES")
meanetl.ef
summary(meanetl.ef)
meanetl.ef$frontier

#' Chart the mean-ES efficient frontier.
chart.EfficientFrontier(meanetl.ef, match.col="ES", main="mean-ETL Efficient Frontier", type="l", col="blue", RAR.text="STARR")
chart.EF.Weights(meanetl.ef, colorset=bluemono, match.col="ES")
chart.EF.Weights(meanetl.ef, by.groups=TRUE, colorset=bluemono, match.col="ES")

#' Compute the mean-ES efficient frontier using random portfolios to solve
#' the optimization problem.
meanetl.rp.ef <- create.EfficientFrontier(R=R, portfolio=meanetl.portf, type="random", match.col="ES")
chart.EfficientFrontier(meanetl.rp.ef, match.col="ES", main="mean-ETL RP Efficient Frontier", type="l", col="blue", rf=0)
chart.EF.Weights(meanetl.rp.ef, colorset=bluemono, match.col="ES")

# mean-etl efficient frontier with optimize.portfolio output
opt_meanetl <- optimize.portfolio(R=R, portfolio=meanetl.portf, optimize_method="random", search_size=2000, trace=TRUE)
chart.EfficientFrontier(meanetl.rp.ef, match.col="ES", main="mean-ETL RP Efficient Frontier", type="l", col="blue", rf=0, RAR.text="STARR")

#' Create a mean-var efficient frontier for multiple portfolios and overlay 
#' the efficient frontier lines. Set up an initial portfolio with the full 
#' investment constraint and mean and var objectives.
init.portf <- portfolio.spec(assets=funds)
init.portf <- add.constraint(portfolio=init.portf, type="full_investment")

#' Portfolio with long only constraints.
lo.portf <- add.constraint(portfolio=init.portf, type="long_only")

#' Portfolio with box constraints.
box.portf <- add.constraint(portfolio=init.portf, type="box", min=0.05, max=0.65)

#' Portfolio with group constraints (also add long only constraints to the 
#' group portfolio).
group.portf <- add.constraint(portfolio=init.portf, type="group", 
                              groups=list(groupA=c(1, 3),
                                          groupB=c(2, 4, 5)),
                              group_min=c(0.25, 0.15), 
                              group_max=c(0.75, 0.55))
group.portf <- add.constraint(portfolio=group.portf, type="long_only")

#' Combine the portfolios into a list.
portf.list <- combine.portfolios(list(lo.portf, box.portf, group.portf))

#' Plot the efficient frontier overlay of the portfolios with varying constraints.
legend.labels <- c("Long Only", "Box", "Group + Long Only")
chart.EfficientFrontierOverlay(R=R, portfolio_list=portf.list, type="mean-StdDev", 
                               match.col="StdDev", legend.loc="topleft", 
                               legend.labels=legend.labels, cex.legend=0.6,
                               labels.assets=FALSE, pch.assets=18)

#' Efficient frontier in mean-ES space with varying confidence leves for
#' ES calculation.
ES90 <- add.objective(portfolio=lo.portf, type="risk", name="ES", 
                          arguments=list(p=0.9))

ES92 <- add.objective(portfolio=lo.portf, type="risk", name="ES", 
                          arguments=list(p=0.92))

ES95 <- add.objective(portfolio=lo.portf, type="risk", name="ES", 
                      arguments=list(p=0.95))

#' Combine the portfolios into a list.
portf.list <- combine.portfolios(list(ES.90=ES90, ES.92=ES92, ES.95=ES95))

#' Plot the efficient frontier overlay of the portfolios with varying 
#' confidence levels fot he ES calculation.
legend.labels <- c("ES (p=0.9)", "ES (p=0.92)", "ES (p=0.95)")
chart.EfficientFrontierOverlay(R=R, portfolio_list=portf.list, type="mean-ES", 
                               match.col="ES", legend.loc="topleft", 
                               legend.labels=legend.labels, cex.legend=0.6,
                               labels.assets=FALSE, pch.assets=18)

