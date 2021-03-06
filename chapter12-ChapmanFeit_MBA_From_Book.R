###################################
# Code for: R for Marketing Research and Analytics, Chapter 12
#
# Authors:  Chris Chapman               Elea McDonnell Feit
#           cnchapman+rbook@gmail.com   efeit@drexel.edu
#
# Copyright 2015, Springer 
#
# Last update: January 7, 2015
# Version: 1.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
#
# You may obtain a copy of the License at
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#################################################################
# BRIEF HOW TO USE
# This file contains scripts used in Chapter 12 of Chapman & Feit (2015),
#   "R for Marketing Research and Analytics", Springer. 
#################################################################

# Chapter 12 -- Association rules

# packages if needed:
# install.packages(c("arules", "arulesViz"))


# Quick example with small data set: "Groceries" data from arules package
# 
library(arules)
data("Groceries")
summary(Groceries)
inspect(head(Groceries, 3))


groc.rules <- apriori(Groceries, parameter=list(supp=0.01, conf=0.3, 
                                                target="rules"))

#Apriori

#Parameter specification:
#  confidence minval smax arem  aval originalSupport maxtime support minlen maxlen target
#0.3    0.1    1 none FALSE            TRUE       5    0.01      1     10  rules
#ext
#FALSE

#Algorithmic control:
#  filter tree heap memopt load sort verbose
#0.1 TRUE TRUE  FALSE TRUE    2    TRUE

#Absolute minimum support count: 98 

#set item appearances ...[0 item(s)] done [0.00s].
#set transactions ...[169 item(s), 9835 transaction(s)] done [0.01s].
#sorting and recoding items ... [88 item(s)] done [0.00s].
#creating transaction tree ... done [0.00s].
#checking subsets of size 1 2 3 4 done [0.00s].
#writing ... [125 rule(s)] done [0.00s].
#creating S4 object  ... done [0.00s].
inspect(subset(groc.rules, lift > 3))
#lhs                                  rhs                support confidence lift
#[1] {beef}                            => {root vegetables}  0.017   0.33       3.0 
#[2] {citrus fruit,root vegetables}    => {other vegetables} 0.010   0.59       3.0 
#[3] {citrus fruit,other vegetables}   => {root vegetables}  0.010   0.36       3.3 
#[4] {tropical fruit,root vegetables}  => {other vegetables} 0.012   0.58       3.0 
#[5] {tropical fruit,other vegetables} => {root vegetables}  0.012   0.34       3.1 


### larger data set
### retail transactions and association rules

# data from Brijs et al 1999, with permission
# data description: http://fimi.ua.ac.be/data/retail.pdf
# paper writeup:    http://alpha.uhasselt.be/~brijs/pubs/kdd99.pdf

# get the data -- original location; Data is indexed as 1,2,3....
retail.raw <- readLines("http://fimi.ua.ac.be/data/retail.dat")

# alternative locations
retail.raw <- readLines("http://goo.gl/FfjDAO")
retail.raw <- readLines("http://r-marketing.r-forge.r-project.org/data/retail.dat")
#

head(retail.raw)
#[1] "0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 "
#[2] "30 31 32 "    --There are three items in this basket                                                                   
#[3] "33 34 35 "                                                                       
#[4] "36 37 38 39 40 41 42 43 44 45 46 "                                               
#[5] "38 39 47 48 " --There are four items in this basket                                                                 
#[6] "38 39 48 49 50 51 52 53 54 55 56 57 58 " 
tail(retail.raw)
summary(retail.raw)        # off by 1 from Brijs et al, but Brijs says is OK
#Length     Class      Mode 
#88162 character character 
# convert the raw character lines into a list of item vectors
?strsplit
retail.list <- strsplit(retail.raw, " ")
names(retail.list) <- paste("Trans", 1:length(retail.list), sep="")
#names(retail.list)
str(retail.list)
#List of 88162
#$ Trans1    : chr [1:30] "0" "1" "2" "3" ...
#$ Trans2    : chr [1:3] "30" "31" "32"
#$ Trans3    : chr [1:3] "33" "34" "35"
#$ Trans4    : chr [1:11] "36" "37" "38" "39" ...
#$ Trans5    : chr [1:4] "38" "39" "47" "48"
tail(retail.list)  # Should end with Trans88162
#$Trans88160
#[1] "2310" "4267"
#$Trans88161
#[1] "39"   "48"   "2528"
#$Trans88162
#[1] "32"   "39"   "205"  "242"  "1393"

library(car)
some(retail.list)    #Samples a few transactions from the retail.list
#$Trans4220
#[1] "18"   "32"   "39"   "123"  "209"  "1966" "2631" "4201" "5323"
#$Trans19170
#[1] "725"  "762"  "973"  "1945"
#$Trans26969
#[1] "32"    "38"    "39"    "41"    "371"   "2195"  "3759"  "4801"  "10863"rm(retail.raw)

retail.trans <- as(retail.list, "transactions")
summary(retail.trans)
#transactions as itemMatrix in sparse format with
#88162 rows (elements/itemsets/transactions) and
#16470 columns (items) and a density of 0.00063 
#most frequent items:
#  39      48      38      32      41 (Other) 
#50675   42135   15596   15167   14945  770058 

rm(retail.list)
retail.rules <- apriori(retail.trans, parameter=list(supp=0.001, conf=0.4))

# plot the rules
library(arulesViz)

plot(retail.rules)

# interactive inspection
plot(retail.rules, interactive=TRUE)

###
# subset of rules: find top 50 sorted by lift
retail.hi <- head(sort(retail.rules, by="lift"), 50)
inspect(retail.hi)

# graph plot
plot(retail.hi, method="graph", control=list(type="items"))

###
# explore profit margin by transaction / rules

# we assume you would have item margins somewhere else, but ...
# for demonstration here we will create a data frame to hold fake margin data

# first get a list of all the items in our transaction set
retail.itemnames <- sort(unique(unlist(as(retail.trans, "list"))))
head(retail.itemnames); tail(retail.itemnames)

# then generate fake "margin" per item
set.seed(03870)
retail.margin <- data.frame(margin=rnorm(length(retail.itemnames), 
                                         mean=0.30, sd=0.30))
quantile(retail.margin$margin)

# and make that indexable by item name
rownames(retail.margin) <- retail.itemnames
# check it
head(retail.margin); tail(retail.margin)
library(car); some(retail.margin)

# now we can get the "total margin" for a basket (assuming quantity 1 unless repeated)
retail.margin[c("39", "48"),]
sum(retail.margin[c("39", "48"),])

# and it also works for transactions coerced to list format
# we'll just pick transaction 3 for convenience
(basket.items <- as(retail.trans[3], "list")[[1]])
retail.margin[basket.items, ]
sum(retail.margin[basket.items, ])

# Now we'll make the task of adding up the margins into a function
#
# note that we really *should* be doing a complete S4 method ... but that's outside the
#   scope of this book. For an intro to that task, see:
#   http://cran.r-project.org/web/packages/Brobdingnag/vignettes/brob.pdf
#
retail.margsum <- function(items, itemMargins) {
  # Input: "items" == item names, rules or transactions in arules format
  #        "itemMargins", a data frame of profit margin indexed by name
  # Output: look up the item margins, and return the sum
  library(arules)
  
  # check the class of "items" and coerce appropriately to an item list
  if (class(items) == "rules") {
    tmp.items <- as(items(items), "list")       # rules ==> item list
  } else if (class(items) == "transactions") {
    tmp.items <- as(items, "list")              # transactions ==> item list
  } else if (class(items) == "list") {
    tmp.items <- items                          # it's already an item list!
  } else if (class(items) == "character") {
    tmp.items <- list(items)                    # characters ==> item list
  } else {
    stop("Don't know how to handle margin for class ", class(items))
  }
  # make sure the items we found are all present in itemMargins
  good.items <- unlist(lapply(tmp.items, function (x) 
                       all(unlist(x) %in% rownames(itemMargins))))
  
  if (!all(good.items)) {
    warning("Some items not found in rownames of itemMargins. ", 
            "Lookup failed for element(s):\n",
            which(!good.items), "\nReturning only good values.")
    tmp.items <- tmp.items[good.items]
  }
  
  # and add them up
  return(unlist(lapply(tmp.items, function(x) sum(itemMargins[x, ]))))
}

retail.margsum(c("39", "48"), retail.margin)
retail.margsum(list(t1=c("39", "45"), t2=c("31", "32")), retail.margin)
retail.margsum(retail.trans[101:103], retail.margin)
retail.margsum(retail.hi, retail.margin)

retail.margsum(c("hello", "world"), retail.margin)  # error!
retail.margsum(list(a=c("39", "45"), b=c("hello", "world"), c=c("31", "32")), 
               retail.margin)    # only the first and third are OK

######


### try with segment data
# get seg.df from Chapter 5
# change the location of the file if you saved it elsewhere
load("~/segdf-Rintro-Ch5.RData")
# OR
seg.df <- read.csv("http://goo.gl/qw303p")
summary(seg.df)

# recode continuous and counts to be all factors
seg.fac <- seg.df
summary(seg.fac)

seg.fac$age <- cut(seg.fac$age, 
                   breaks=c(0,25,35,55,65,100), 
                   labels=c("19-24", "25-34", "35-54", "55-64", "65+"), 
                   right=FALSE, ordered_result=TRUE)
summary(seg.fac$age)

seg.fac$income <- cut(seg.fac$income, 
                      breaks=c(-100000, 40000, 70000, 1000000),
                      labels=c("Low", "Medium", "High"),
                      right=FALSE, ordered_result=TRUE)

seg.fac$kids <- cut(seg.fac$kids, 
                      breaks=c(0, 1, 2, 3, 100),
                      labels=c("No kids", "1 kid", "2 kids", "3+ kids"),
                      right=FALSE, ordered_result=TRUE)

summary(seg.fac)


#### exploring segment associations

# load packages
library(arules)
library(arulesViz)

# convert to arules transaction format for simplicity
seg.trans <- as(seg.fac, "transactions")
summary(seg.trans)

# find some initial rules
seg.rules <- apriori(seg.trans, parameter=list(support=0.1, conf=0.4, 
                                               target="rules"))
summary(seg.rules)

plot(seg.rules)

# examine some of the higher-lift rules
seg.hi <- head(sort(seg.rules, by="lift"), 35)
inspect(seg.hi)

# 
plot(seg.hi, method="graph", control=list(type="items"))  # note, plot orientation is random

# continue down the list by lift
seg.next <- sort(seg.rules, by="lift")[36:60]
plot(seg.next, method="graph", control=list(type="items"))  # not shown


##### EXTRAS
## partial rule matching -- NOT SHOWN IN BOOK
seg.sub <- head(sort(subset(seg.rules, 
             subset=(rhs %pin% "Urban" | rhs %pin% "subscribe") & lift > 1), 
             by="lift"), 100)
summary(seg.sub)

# grouped plot -- not in book
plot(seg.sub, method="grouped")
#####
