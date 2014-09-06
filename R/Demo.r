
# run: CustomMath, ConsensusMechanism, and PlotJ first
ToMatrix <- function(DF) {
  RowNames <- row.names(DF)
  DFn <- data.frame ( lapply( DF, as.numeric) ) # make all observations numbers
  Matrix <- as.matrix(DFn,ncol = ncol(DF)) # save in matrix format
  row.names(Matrix) <- RowNames  # restore row names (lost during as.numeric)
  return(Matrix)
}

truthcoindemo <- function(csvdata) {

print("Loading data..")
con <- textConnection(csvdata)
Data <- read.csv(con, stringsAsFactors= FALSE, row.names=1)
close(con)
print("Load Complete.")
print(" ")

## Get VoteMatrix ##
print("Getting Votes..")

# Remove header info
VoteData <- Data[-1:-4,]
VoteMatrix <- ToMatrix(VoteData)

print(VoteMatrix)
print(" ")


## Rescale ##
print("Rescaling the Scaled Decisions..")

# Scaled claims must become range(0,1)

Scaled <- Data["Qtype",] == "S" # which of these are scaled at all?

# Rescale
ScaleData <- Data[c("Min", "Max"),Scaled] # get the scales from the 'Qtype' row, and nothing else
ScaleMatrix <- ToMatrix(ScaleData)


RescaledVoteMatrix <- VoteMatrix # declare destination data
for(i in 1:ncol(ScaleMatrix)) { # for each scaled decision
  
  ThisQ <- colnames(ScaleMatrix)[i]
  ThisColumn <- RescaledVoteMatrix[ , colnames(RescaledVoteMatrix)==ThisQ ] # match the right column
  RescaledColumn <- (ThisColumn - ScaleMatrix["Min",i]) / (ScaleMatrix["Max",i] - ScaleMatrix["Min",i])  # "rescale"
  
  RescaledVoteMatrix[ , colnames(RescaledVoteMatrix)==ThisQ ] <- RescaledColumn # Overwrite
}

print("Rescale Complete.")
print(" ")


## Do Computations ##

# I've already rescaled, but we still need to pass the boolean - must fix this.
ScaleData <- matrix( c( rep(FALSE,ncol(RescaledVoteMatrix)),
              rep(0,ncol(RescaledVoteMatrix)),
              rep(1,ncol(RescaledVoteMatrix))), 3, byrow=TRUE, dimnames=list(c("Scaled","Min","Max"),colnames(RescaledVoteMatrix)) )

ScaleData[1,] <- Scaled

# Get the Resuls
print("Calculating Results..")
SvdResults <- Factory(RescaledVoteMatrix, Scales = ScaleData)

print("Original")
print(SvdResults$Original)
print(" ")
print("Agents")
print(SvdResults$Agents)
print(" ")
print("Decisions")
print(SvdResults$Decisions)
print(" ")

print( PlotJ(RescaledVoteMatrix, Scales = ScaleData) )

invisible()
}

# this works
truthcoindemo("Label,QID1,QID2,QID3,QID4,QID5,QID6,QID7,QID8,QID9,QID10\r\nQtext,\"In the United States, following the 2012 November / elections, was Barack Obama elected US President?\",\"In the United States, following the 2012 November / elections, was Mitt Romney elected US President?\",\"In the United States, following the 2012 November / elections, did the Democratic Party control 51...\",\"In the United States, following the 2012 November / elections, did the Republican Party control 218...\",\"In the United States, following the 2012 November / elections, how many seats in the House of Repre...\",\"During the 2011-2012 United States football season, did the New / England Patriots (AFC) win the 20...\",\"During the 2013-2014 United States football season, did the Denver / Broncos (AFC) win the 2014 Sup...\",\"On June 27th, 2014, was the closing price of the Dow Jones / Industrial Average (INDEXDJX:.DJI) abo...\",\"On June 27th, 2014, was the closing price of the SPDR Gold Trust / (ETF) (NYSEARCA:GLD) above 120?\",\"On July 9th, 2014, what was the closing price of the Dow Jones / Industrial Average (INDEXDJX:.DJI,...\"\r\nQtype,B,B,B,B,S,B,B,B,B,S\r\nMin,0,0,0,0,0,0,0,0,0,8000\r\nMax,1,1,1,1,538,1,1,1,1,20000\r\nVoter 1,1,0,1,1,242,0,0,1,1,16985.61\r\nVoter 2,0,0.5,0.5,,240,0,0,1,0,16985.61\r\nVoter 3,1,0,1,1,242,0,0,1,1,")
# the image appears in editor

