#
#  Script for extracting x,y,z positions from confocal scans and then combining them
#  with cell count table from ImageJ script.
#
#  xyzpositions.maf is an XML file from Leica Confocal software.
# 

# Redefine length function
length2 <- function(v, na.rm=FALSE) {
  # Go home NA, no one likes you.
  return( ifelse(na.rm==TRUE, length(v[!is.na(v)]), length(v)) )
}

# XML parsing code to extract actual x,y positions (in case someone actually cares).
xml.file <- xmlInternalTreeParse("xypositions.maf")
stageXPositionsMeters <- xpathApply(xml.file, "//XYZStagePointDefinition[@StageXPos]", xmlGetAttr, "StageXPos")
stageYPositionsMeters <- xpathApply(xml.file, "//XYZStagePointDefinition[@StageYPos]", xmlGetAttr, "StageYPos")
stageYPositionsMeters <- substring(stageYPositionsMeters, 1, 5)
stagePositionsIndices <- xpathApply(xml.file, "//XYZStagePointDefinition[@PositionID]", xmlGetAttr, "PositionID")

# xyzPositions data is actually the data for x and y positions only
xyzPositions.data <- data.frame(
  x  = as.numeric(stageXPositionsMeters),
  y  = round(as.numeric(stageYPositionsMeters), digits=3),
  ID = as.numeric(stagePositionsIndices)
)

# Leica software creates folders that are not properly padded with zeros,
# so let's correct this.
xyzPositions.data$IDstring <- paste("x", xyzPositions.data$ID, "", sep="")
xyzPositions.data <- xyzPositions.data[order(xyzPositions.data$IDstring),]
xyzPositions.data$orderedID <- seq(1, max(xyzPositions.data$ID))

#
#                                Calculate statistics.
#

# Discard the rows where area=1000, these are fakes.
all.data[all.data$Area==1000,]$Area <- NA

cellCounts2.data <- ddply(
  all.data,
  .(tFrameTimeIndex, xyFramePositionIndex, zFramePositionIndex, group),
  summarize, meanArea=mean(Area, na.rm=TRUE), counts=length2(Area)-1
)

# Join xy positions with cell counts data
uniqueZ <- length(unique(all.data$zFramePositionIndex))
uniqueXY <- length(unique(all.data$xyFramePositionIndex))
xyzPositions.data$xyFramePositionIndex <- xyzPositions.data$orderedID
cellCounts2.data <- merge(cellCounts2.data, xyzPositions.data, by="xyFramePositionIndex")
cellCounts2.data$xCm <- (cellCounts2.data$x - min(cellCounts2.data$x))*100

# Now average by y and z
cellCounts2yzavg.data <- ddply(
  cellCounts2.data,
  .(x, tFrameTimeIndex, group),
  summarize, meanMeanArea = mean(meanArea), counts=mean(counts)
)

# Convert to normal units. Multiply x by 100 to get the number in centimeters
cellCounts2yzavg.data$tHours <- (cellCounts2yzavg.data$tFrameTimeIndex - 1)*dt
cellCounts2yzavg.data$xCm <- (cellCounts2yzavg.data$x - min(cellCounts2yzavg.data$x))*100

cellCounts2yzavg.data <- subset(
  cellCounts2yzavg.data,
  cellCounts2yzavg.data$xCm %in% unique(cellCounts2yzavg.data$xCm)[seq(0, length(unique(cellCounts2yzavg.data$xCm)), 1)]
)

xCmForPlot <- sort(unique(cellCounts2.data$xCm))[seq(0, length(sort(unique(cellCounts2.data$xCm))), 1)]

# Global growth curve
cellCountsTotal.data <- ddply(
  subset(cellCounts2.data, cellCounts2.data$xCm %in% xCmForPlot),
  .(tFrameTimeIndex, group),
  summarize, countsAverage=sum(counts)*length(sort(unique(cellCounts2.data$xCm)))/(uniqueZ*uniqueXY*length(xCmForPlot)), countsTotal=sum(counts)
)

# Add time in hours
cellCountsTotal.data$tHours <- (cellCountsTotal.data$tFrameTimeIndex-1)*dt
cellCounts2yzavg.data$tHrs <- cellCounts2yzavg.data$tHours
