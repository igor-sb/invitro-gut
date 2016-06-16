#
#   dLac GFP and gGal mCh, 2mM lactose 
#   2 PSI flow, 0.03% PAM, 10cm capillary
#   3 min peristalsis period, 
#
#   I added a longer capillary to further slow the flow rate.
#
#
#   Author: Igor Segota
#   Date: 2015-06-24
#

# Clear all variables
rm(list=ls(all=TRUE))

# Load libraries
library(ggplot2)
library(stringr)
library(scales)
library(XML)
library(plyr)

setwd("/Users/Igor/Dropbox/Research/Minigut/2015-10-29_dlac_dgal_4psiflow_nopss/data")

# Time interval between images in seconds (usually 20 minutes)
dt <- 20/60

# Load data
GFP.data <- read.table("Results_dlac.xls", sep="\t", header=T)
GFP.data$group <- "GFP"
mCh.data <- read.table("Results_dgal.xls", sep="\t", header=T)
mCh.data$group <- "mCh"

# Merge into one data frame and relabel columns
all.data <- merge(GFP.data, mCh.data, all=T)
colnames(all.data) <- c("ID", "Area", "X", "Y", "tFrameTimeIndex", "xyFramePositionIndex", 
                        "zFramePositionIndex", "group")
invalidAreas <- c(1, 1337)
all.data <- all.data[!(all.data$Area %in% invalidAreas),]

# Load common part for processing and summarizing data
source("../cell_density_statistics_2strains.R")


#
#   Plot averaged cell profiles
#

plotTextSize <- 14

# Plot these time points
t.display <- c(1, 2, 3, seq(4,38,by=1))

cellCounts2yzavg.data$tHrs <- cellCounts2yzavg.data$tHours
cellCounts.plot <- ggplot(
  cellCounts2yzavg.data[cellCounts2yzavg.data$group=="mCh" & 
                        cellCounts2yzavg.data$tFrameTimeIndex %in% t.display & 
                        cellCounts2yzavg.data$xCm %in% unique(cellCounts2yzavg.data$xCm)[
                                seq(2,length(unique(cellCounts2yzavg.data$xCm))-1,by=2)
                                ],
                       ],
  aes(x=xCm, y=counts, color=group, group=group)
)
cellCounts.plot + geom_point(size=5) + geom_line(size=2) + theme_bw() +
  facet_wrap(~ tHrs, ncol=5) +
  scale_x_continuous("distance along the channel [cm]", breaks=seq(0,6,by=1)) +
  scale_y_continuous("cell count, linear scale", breaks=seq(0,1000,250)) + 
  coord_cartesian(ylim=c(0,300), xlim=c(0,5.5)) +
  scale_color_manual("strain", values = c("GFP" = "dark green", "mCh" = "red")) +
  theme(
    text=element_text(size=plotTextSize, color="black"),
    axis.text = element_text(size=plotTextSize, color="black"),
    axis.title = element_text(size=plotTextSize, color="black"),
    legend.text = element_text(size=plotTextSize, color="black"),
    legend.title = element_text(size=plotTextSize, color="black", face="plain"),
    legend.key = element_blank(),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(linetype="dashed")
  )


# Export averaged data with this: 
# a = cellCounts2yzavg.data[cellCounts2yzavg.data$group=="mCh" & 
#                           cellCounts2yzavg.data$tFrameTimeIndex %in% t.display & 
#                           cellCounts2yzavg.data$xCm %in% unique(cellCounts2yzavg.data$xCm)[
#                              seq(2,length(unique(cellCounts2yzavg.data$xCm))-1,by=2)
#                           ],
#                          ]
# write.table(a, "cell_profiles_avg_yz_v4_D0.txt", sep="\t", row.names=F)


# If we want to export data to python, run this:
# write.table(cellCounts2yzavg.data[cellCounts2yzavg.data$tFrameTimeIndex %in% t.display & 
#                                   cellCounts2yzavg.data$xCm %in% unique(cellCounts2yzavg.data$xCm)[
#                                      seq(2,length(unique(cellCounts2yzavg.data$xCm))-1,by=2)
#                                   ],
#                                  ], 
#             file="TwoStrain-2umsflow-nomixing-WashoutData.txt", sep="\t")


#
# Plot global growth curve
#

cellCountsTotal.plot <- ggplot(cellCountsTotal.data, aes(x=tHours/2.61, y=countsTotal, 
                                                         group=group, color=group))
cellCountsTotal.plot + geom_point(size=5) + geom_line(size=2) + theme_bw() +
  scale_x_continuous("time (hours)", limits=c(0,20), breaks=seq(0,20,by=2)) +
  scale_y_continuous("total cell count (log scale)", trans="log10", 
                     breaks=c(10,100,1000,10000,10000), limits=c(1e1,2e4)) +
  # Change colors for GFP, mCh
  scale_color_manual(values= c("GFP" = "dark green", "mCh" = "red")) +
  annotation_logticks(sides = "l") +
  theme(
    text=element_text(size=plotTextSize, color="black"),
    axis.text = element_text(size=plotTextSize, color="black"),
    axis.title = element_text(size=plotTextSize, color="black"),
    legend.text = element_text(size=plotTextSize, color="black"),
    legend.title = element_text(size=plotTextSize, color="black", face="plain"),
    legend.key = element_blank(),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(linetype="dashed")
  )

# Plot cell profile as a function of z, first for an individual xy position,
# then averaged over all xy.

# We can start from cellCounts2.data which I did ddply to get.
xy.select <- 36
cellCounts.subdata <- cellCounts2.data[
  cellCounts2.data$xyFramePositionIndex==xy.select & cellCounts2.data$tFrameTimeIndex %in% seq(1,87,by=3),
  ]
cellCounts.subdata$t <- round( (cellCounts.subdata$tFrameTimeIndex-1)*dt, 2)
cellCounts.subdata$counts <- cellCounts.subdata$counts-1


cellCounts.zplot <- ggplot(
  cellCounts.subdata, 
  aes(x=zFramePositionIndex, y=counts, group=factor(t), color=factor(t))
)
cellCounts.zplot + geom_point(size=4) + geom_line(size=2) + theme_bw() +
  facet_wrap(~ t, ncol=5) +
  scale_x_continuous("z coordinate", breaks=seq(0,10,by=1))


# Prepare a new data frame cellCountsTAvg.data for linear fits later
t.s   <- sort(unique(cellCounts.data$t))
t.len <- length(t.s)
t.sds <- rep(0, t.len)
t.counts <- rep(0, t.len)

for (tID in seq(1, t.len)) {
  # for each time point average all the counts
  t.subdata <- cellCounts.data[cellCounts.data$t == t.s[tID],]
  t.counts[tID] <- mean(t.subdata$count)
  t.sds[tID]    <- sd(t.subdata$count)
}

cellCountsTAvg.data <- data.frame(
  t = t.s,
  tHrs = (t.s-1)*dt,
  count = t.counts,
  sds = t.sds
)


# Select time points to fit a line, to extract a growth rate
tFitMin <- 0
tFitMax <- 5.5
plotTextSize <- 14

cellCounts.subdata <- subset(
  cellCounts.data, 
  y == unique(cellCounts.data$y)[2] &
    xNorm %in% x.display &
    t %in% seq(1,103)
)

# Do linear fit
linearFit <- lm(
  log2(cellCountsTAvg.data[cellCountsTAvg.data$tHrs > tFitMin & 
                           cellCountsTAvg.data$tHrs < tFitMax,]$count) ~ 
    cellCountsTAvg.data[cellCountsTAvg.data$tHrs > tFitMin & 
                        cellCountsTAvg.data$tHrs < tFitMax,]$tHrs
)

cellCountsTAvg.data$dataFit <- 2^(as.numeric(linearFit$coefficients[1])) * 
                               2^(as.numeric(linearFit$coefficients[2])*cellCountsTAvg.data$tHrs)
cellCountsTAvg.data[cellCountsTAvg.data$tHrs < tFitMin | cellCountsTAvg.data$tHrs > tFitMax,]$dataFit <- 0


# Plot average growth curve
cellCountsFacet.plot <- ggplot(
  cellCountsTAvg.data[cellCountsTAvg.data$t<=44,],
  aes(x=tHrs, y=count, ymin=count-sds, ymax=count+sds)
)
cellCountsFacet.plot + 
  geom_point(size=5, color="#F8766D") + 
  geom_line(aes(y=dataFit), data=cellCountsTAvg.data[cellCountsTAvg.data$tHrs<=tFitMax,], 
            color="black", linetype="dashed", size=1) + theme_bw() +
  scale_x_continuous("time (hours)", breaks=seq(0,20,1)) +
  scale_y_continuous("cell count", trans="log10",breaks=c(1,10,30,100,300,1000,3000), 
                     limits=c(50,3000)) +
  annotation_logticks(sides = "l") +
  ggtitle("flow speed: 3um/s, with peristalsis each minute") +
  theme(
    text=element_text(size=plotTextSize, color="black"),
    axis.text = element_text(size=plotTextSize, color="black"),
    axis.title = element_text(size=plotTextSize, color="black"),
    legend.text = element_text(size=plotTextSize, color="black"),
    legend.title = element_text(size=plotTextSize, color="black", face="plain"),
    legend.key = element_blank(),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(linetype="dashed")
  )
