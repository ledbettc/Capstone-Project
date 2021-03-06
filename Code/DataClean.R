### This file cleans and merges the original data sets and creates the final data set ###
### used for analysis. ###

# data sets for each year with only pertinant variables is stored as 
# ~/Repositories/Data/Capstone/allbyyear.RData

# the final analysis data set is stored as 
# ~/Repositories/Data/Capstone/analysis.rda

# import workspace from DataImport containing all orig data. 
# (created in Code/DataImport.r)
load(file = '~/Repositories/Data/Capstone/original_all.Rdata')

# create variable for year cycles
allcyc <- c(1999,2001,2003,2005,2007,2009,2011,2013)

#########################################################################################
############### For each data set and cycle keep only relevant variables ################
#########################################################################################

#########################################################################################
# for Food Security Questionnaire only need food security variable (ADFDSEC for 1999-2002
# and FSDAD for 2003-2014) and seqn (identifier) 

# rename adfdsec so names are the same

FSQ1999 <- FSQ1999[,c('seqn', 'adfdsec')]
names(FSQ1999)[2] <- 'fsdad'
FSQ2001 <- FSQ2001[,c('seqn', 'adfdsec')]
names(FSQ2001)[2] <- 'fsdad'

for(i in allcyc[3:8]){
  ds <- get(paste('FSQ', i, sep = ''))
  assign(paste('FSQ', i, sep = ''), ds[,c('seqn', 'fsdad')])
}; remove(i,ds)


########################################################################################
# for fasting glucose need 4 year weight for 1999-2002, 2 year weight for all others, 
# lbxglu(fasting glucose), and seqn, rename weighting variable so it's the same in all 
# datasets

FGI1999 <- FGI1999[,c('seqn', 'wtsaf4yr', 'lbxglu')]
names(FGI1999)[2] <- 'svywgt'
FGI2001 <- FGI2001[,c('seqn', 'wtsaf4yr', 'lbxglu')]
names(FGI2001)[2] <- 'svywgt'

for(i in allcyc[3:8]){
  ds <- get(paste('FGI', i, sep = ''))
  ds <- ds[,c('seqn', 'wtsaf2yr', 'lbxglu')]
  names(ds)[2] <- 'svywgt'
  assign(paste('FGI', i, sep = ''), ds)
}; remove(i,ds)


#########################################################################################
#for medication to lower blood sugar need question for medication

for(i in allcyc[c(1:3,6:8)]){
  ds <- get(paste('DIQ', i, sep = ''))
  assign(paste('DIQ', i, sep = ''), ds[,c('seqn', 'diq070')])
}; remove(i,ds)

#variable name was changed for 2005, 2007, rename so they're all the same
DIQ2005 <- DIQ2005[,c('seqn', 'did070')]
names(DIQ2005)[2]<- 'diq070'
DIQ2007 <- DIQ2007[,c('seqn', 'did070')]
names(DIQ2007)[2]<- 'diq070'


########################################################################################
# for body measures data need BMXWAIST (waist circumference), BMXBMI (BMI) and seqn

for(i in allcyc){
  ds <- get(paste('BMD', i, sep = ''))
  assign(paste('BMD', i, sep = ''), ds[,c('seqn', 'bmxwaist', 'bmxbmi')])
}; remove(i,ds)


########################################################################################
# for blood pressure need average systolic and diastolic

BPD1999 <- BPD1999[,c('seqn', 'bpxsar', 'bpxdar')]
BPD2001 <- BPD2001[,c('seqn', 'bpxsar', 'bpxdar')]
BPD2003 <- BPD2003[,c('seqn', 'bpxsar', 'bpxdar')]

#after 2003 NHANES did not provide average so needs to be calculated
for(i in allcyc[4:8]){
  ds <- get(paste('BPD', i, sep = ''))
  ds$bpxsar <- mean(c(ds$bpxsy1, ds$bpxsy2, ds$bpxsy3, ds$bpxsy4), na.rm = T)
  ds$bpxdar <- mean(c(ds$bpxdi1, ds$bpxdi2, ds$bpxdi3, ds$bpxdi4), na.rm = T)
  assign(paste('BPD', i, sep = ''), ds[,c('seqn', 'bpxsar', 'bpxdar')])
}; remove(i,ds)


#########################################################################################
# for blood pressure/cholesterol medication need hypertension med and cholesterol med 
# questions

for(i in allcyc){
  ds <- get(paste('BPQ', i, sep = ''))
  assign(paste('BPQ', i, sep = ''), ds[,c('seqn', 'bpq050a', 'bpq090d', 'bpq100d')])
}; remove(i,ds)


##########################################################################################
# for triglycerides need LBXTR (trigylcerides) and seqn

for(i in allcyc){
  ds <- get(paste('TRG', i, sep = ''))
  assign(paste('TRG', i, sep = ''), ds[,c('seqn', 'lbxtr')])
}; remove(i,ds)


##########################################################################################
# for HDL need HDL (lbdhdl for 1999-2002 and lbxhdd for 2003-2004 and lbdhdd for 
# 2005-2014) and seqn,
# rename HDL so it is the same in all datasets

HDL1999 <- HDL1999[,c('seqn', 'lbdhdl')]
names(HDL1999)[2] <- 'hdl'
HDL2001 <- HDL2001[,c('seqn', 'lbdhdl')]
names(HDL2001)[2] <- 'hdl'
HDL2003 <- HDL2003[,c('seqn', 'lbxhdd')]
names(HDL2003)[2] <- 'hdl'

for(i in allcyc[4:8]){
  ds <- get(paste('HDL', i, sep = ''))
  ds <- ds[,c('seqn', 'lbdhdd')]
  names(ds)[2] <- 'hdl'
  assign(paste('HDL', i, sep = ''), ds)
}; remove(i,ds)


############################################################################################
# alcohol use (for detailed criteria see data analyis plan)

invisible(lapply(ls(pattern='ALC.*'),
                     function(x) {
                       dat=get(x)
                       dat$alcuse = factor(NaN, levels = c('Never','Moderate', 
                                                           'Heavy'))
                       dat$alcuse[dat$alq110 == 2] <- 'Never' #alq110 = no
                       dat$alcuse[dat$alq130 <=2 ] <- 'Moderate'
                       dat$alcuse[dat$alq130 > 2] <- 'Heavy'
                       dat$alcuse[dat$alq140q > 0] <- 'Heavy'
                       assign(paste(x), dat[c('seqn', 'alcuse')], envir = .GlobalEnv)
                     }))

#########################################################################################
# smoking status (for detailed criteria see data analysis plan)

invisible(lapply(ls(pattern='SMQ.*'),
                 function(x) {
                   dat=get(x)
                   dat$smoker = factor(NaN, levels = c('Never','Former', 
                                                       'Current'))
                   dat$smoker[dat$smq020 == 2] <- 'Never' #smq020 = no
                   dat$smoker[dat$smq020 == 1 & dat$smq040 == 3] <- 'Former'
                   dat$smoker[dat$smq020 == 1 & dat$smq040 <= 2] <- 'Current'
                   assign(paste(x), dat[c('seqn', 'smoker')], envir = .GlobalEnv)
                 }))


#########################################################################################
#physical activity need PAD320 Moderate Activity over past 30 days

for(i in allcyc[1:4]){
  ds <- get(paste('PAQ', i, sep = ''))
  ds <- ds[,c('seqn', 'pad320')]
  ds$paq620 <- NA
  ds$paq665 <- NA
  assign(paste('PAQ', i, sep = ''), ds)
}; remove(i,ds)

for(i in allcyc[5:8]){
  ds <- get(paste('PAQ', i, sep = ''))
  ds <- ds[,c('seqn', 'paq620', 'paq665')]
  ds$pad320 <- NA
  assign(paste('PAQ', i, sep = ''), ds)
}; remove(i,ds)


#########################################################################################
# demographics - need data on gender, age, race/ethnicity, pregnancy status, 
# education, income, and PSU and stratum variables for weighting (SDMVPSU, SDMCSTRA)

for(i in allcyc[1:4]){
  ds <- get(paste('DEM', i, sep = ''))
  assign(paste('DEM', i, sep = ''), ds[,c('seqn', 'riagendr', 'ridreth1', 
                                          'ridageyr', 'ridexprg', 'dmdeduc3',
                                          'dmdeduc2','indfminc', 'sdmvpsu',
                                          'sdmvstra')])
}; remove(i,ds)

# in 2007 additional income categories were added, new variable is indfmin2
for(i in allcyc[5:6]){
  ds <- get(paste('DEM', i, sep = ''))
  ds <- ds[,c('seqn', 'riagendr', 'ridreth1', 'ridageyr', 'ridexprg', 
              'dmdeduc3', 'dmdeduc2', 'indfmin2', 'sdmvpsu', 'sdmvstra')]
  names(ds)[8] <- 'indfminc'
  assign(paste('DEM', i, sep = ''), ds)
}; remove(i,ds)


# starting in 2011, NHANES contained a race/ethncity category for asians,
# the ridreth3 variable has been setup to match the ridreth1 variable prior to 
# 2011, need to rename so it matches

for(i in allcyc[7:8]){
  ds <- get(paste('DEM', i, sep = ''))
  ds <- ds[,c('seqn', 'riagendr', 'ridreth3', 'ridageyr', 'ridexprg', 
              'dmdeduc3', 'dmdeduc2', 'indfmin2', 'sdmvpsu', 'sdmvstra')]
  names(ds)[c(3,8)] <- c('ridreth1', 'indfminc') 
  assign(paste('DEM', i, sep = ''), ds)
}; remove(i,ds)






#########################################################################################
########################## Merge all data sets for each cycle  ##########################
#########################################################################################

for(i in allcyc){
  ds1 <- get(paste('FGI', i, sep = ''))
  ds2 <- get(paste('FSQ', i, sep = ''))
  ds1 <- merge(ds1, ds2, by = 'seqn', all.x = T)
  ds2 <- get(paste('BMD', i, sep = ''))
  ds1 <- merge(ds1, ds2, by = 'seqn', all.x = T)
  ds2 <- get(paste('BPD', i, sep = ''))
  ds1 <- merge(ds1, ds2, by = 'seqn', all.x = T)
  ds2 <- get(paste('BPQ', i, sep = ''))
  ds1 <- merge(ds1, ds2, by = 'seqn', all.x = T)  
  ds2 <- get(paste('HDL', i, sep = ''))
  ds1 <- merge(ds1, ds2, by = 'seqn', all.x = T)
  ds2 <- get(paste('TRG', i, sep = ''))
  ds1 <- merge(ds1, ds2, by = 'seqn', all.x = T)
  ds2 <- get(paste('DIQ', i, sep = ''))
  ds1 <- merge(ds1, ds2, by = 'seqn', all.x = T)
  ds2 <- get(paste('DEM', i, sep = ''))
  ds1 <- merge(ds1, ds2, by = 'seqn', all.x = T)
  ds2 <- get(paste('ALC', i, sep = ''))
  ds1 <- merge(ds1, ds2, by = 'seqn', all.x = T)
  ds2 <- get(paste('SMQ', i, sep = ''))
  ds1 <- merge(ds1, ds2, by = 'seqn', all.x = T)
  ds2 <- get(paste('PAQ', i, sep = ''))
  ds1 <- merge(ds1, ds2, by = 'seqn', all.x = T)
  ds1$yr <- i
  assign(paste('all',i, sep = ''), ds1)
}; remove(i,ds1,ds2)

#save final dataset for each year
save(list = ls(pattern = 'all.*'), file = "~/Repositories/Data/Capstone/allbyyear.RData",
     envir = .GlobalEnv)



#########################################################################################
################# Merge all data sets to create analysis dataset  #######################
#########################################################################################

analysis <- do.call(rbind, lapply(allcyc, FUN = function(i) get(paste('all',i, sep = '')) ))

#remove those whose fasting survey weight = 0
analysis <- analysis[analysis$svywgt != 0,]
analysis$samplewgt <- ifelse(analysis$yr %in% c(1999,2001), 1/4*analysis$svywgt,
                             1/8*analysis$svywgt)



#########################################################################################
# clear workspace of all except analysis to tidy up
rm(list=setdiff(ls(), "analysis"))



#########################################################################################
# for each criteria for metabolic syndrome set to 0 (not present) or 1(present)
# leave any missing as missing - for detailed criteria see data analysis plan

# waist cm
analysis$waistcm <- NA
analysis$waistcm[!is.na(analysis$bmxwaist)] <- 0
analysis$waistcm[analysis$bmxwaist >= 102 & analysis$riagendr == 1] <- 1
analysis$waistcm[analysis$bmxwaist >= 88 & analysis$riagendr == 2] <- 1

# blood pressure
analysis$bp <- NA
analysis$bp[!is.na(analysis$bpxsar) & !is.na(analysis$bpxdar)] <- 0
analysis$bp[analysis$bpxsar >= 130 | analysis$bpxdar >= 85] <-1
analysis$bp[analysis$bpq050a == 1] <- 1 

# triglycerides
analysis$tgl <- NA
analysis$tgl[!is.na(analysis$lbxtr)] <- 0
analysis$tgl[analysis$lbxtr >= 150] <- 1
analysis$tgl[analysis$bpq100d == 1] <- 1

# HDL
analysis$hdlelev <- NA
analysis$hdlelev[!is.na(analysis$hdl)] <- 0
analysis$hdlelev[analysis$hdl <40 & analysis$riagendr == 1] <- 1
analysis$hdlelev[analysis$hdl <50 & analysis$riagendr ==2] <- 1

# fasting glucose
analysis$glucose <- NA
analysis$glucose[!is.na(analysis$lbxglu)] <- 0
analysis$glucose[analysis$lbxglu >= 100] <- 1
analysis$glucose[analysis$diq070 == 1] <- 1

# sum criteria, leaving NAs so if any = NA then metabolic = NA.  
analysis$metabolic <- apply(analysis[,c('waistcm', 'bp', 'tgl', 'hdlelev', 'glucose')],
                            MARGIN = 1, sum)

# if more than 3 are present then metabolic syndrome = T
analysis$syndrome <- NA
analysis$syndrome[analysis$metabolic < 3] <- F
analysis$syndrome[analysis$metabolic >= 3] <- T

#########################################################################################
# if food security is 3, or 4 then individual is considered food insecure
analysis$foodinsecure <- NA
analysis$foodinsecure[analysis$fsdad <= 2] <- F
analysis$foodinsecure[analysis$fsdad > 2] <- T


#########################################################################################
# exclude those under 18, over 65 or pregnant, or missing outcome
# must be left in data set due to complex survey design, 
# set exclusion reason for data characterization

analysis$subset <- NA
analysis$exclreason <- NA
analysis$subset[analysis$ridageyr >= 18 & analysis$ridageyr <= 65] <- T
analysis$subset[analysis$ridexprg == 1 | analysis$ridexprg == 3 ] <- F
analysis$exclreason[analysis$ridexprg == 1 | analysis$ridexprg == 3 ] <- 'Pregnancy'
analysis$subset[analysis$ridageyr < 18 | analysis$ridageyr > 65] <- F
analysis$exclreason[analysis$ridageyr < 18 | analysis$ridageyr > 65] <- 'Age'
analysis$subset[is.na(analysis$metabolic)] <- F
analysis$exclreason[is.na(analysis$metabolic)] <- 'Outcome'


#########################################################################################
# set up categorical covariates

# Gender
analysis$Gender <- factor(analysis$riagendr)
levels(analysis$Gender) <- list('Male' = 1, 'Female' = 2)

# Race/Ethnicity
analysis$Race <- factor(analysis$ridreth1)
levels(analysis$Race) <- list('Non-Hispanic White' = 3,'Mexican American' = 1,
                              'Other Hispanic' = 2,
                              'Non-Hispanic Black' = 4, 
                              'Other (including multiracial)' = 5)


# Education

analysis$Education <- factor(analysis$dmdeduc2, exclude = c(NA, 7, 9))
levels(analysis$Education) <- list('Less than 9th Grade' = 1, '9-11th Grade' = 2, 
                          'High School Grad' = 3, 'Some College/AA' = 4, 
                          'College Graduate or above' = 5)

# for 18 and 19 year olds a different question was asked (dmdeduc3)
analysis$Education[analysis$dmdeduc3 < 9 | analysis$dmdeduc3 %in% c(55,66)] <- 'Less than 9th Grade' 
analysis$Education[analysis$dmdeduc3 %in% c(9:12)] <- '9-11th Grade'
analysis$Education[analysis$dmdeduc3 %in% c(12:14)] <- 'High School Grad'
analysis$Education[analysis$dmdeduc3 == 15] <- 'Some College/AA'


# income
analysis$Income <- factor(analysis$indfminc, exclude = c(NA, 12, 77, 99))
levels(analysis$Income) <- list('< $20,000' = c(1:4,13), '$20,000 - $54,999' = 5:8,
                                '$55,000-$74,999' = 9:10,
                                '\\(\\geq\\) $75,000' = c(11, 14:15))

# Moderate Physical Activity
analysis$ModerateActivity <- factor(NA, levels = c('Yes', 'No'))
analysis$ModerateActivity[apply(analysis[,c("pad320", "paq620", "paq665")], 1,
                                function(i) any(i %in% c(2:3), na.rm = T))] <- 'No'
analysis$ModerateActivity[apply(analysis[,c("pad320", "paq620", "paq665")], 1,
                                function(i) any(i == 1, na.rm = T))] <- 'Yes'



#########################################################################################
# exclude those missing covariate information, setup a second variable so they can be 
# characterized easily in table 1. 

analysis$excludecov <- NA
analysis$excludecov <- apply(analysis[, c('Gender', 'Race', 'Education', 'Income', 
                                       'ModerateActivity', 'alcuse', 'smoker', 'ridageyr')],
                          MARGIN = 1, function(x) any(is.na(x)))

# check 
table(analysis$excludecov) #7355 excluded
sapply(analysis[, c('Gender', 'Race', 'Education', 'Income', 'ModerateActivity', 'alcuse',
                    'smoker', 'ridageyr')], function(x) sum(is.na(x)));
# 782 race, 26 Educ, 1161 Income, 1987 PhysAct, 4461 Alcuse, 135 smoker
782+26+1161+1987+4461+135 # = 8552 this makes sense as we would expect some overlap


#########################################################################################
# combine 2 exclusion criteria (include only those in subset = T and exclude those for 
# whom excludecov = T, also exclude those missing exposure)

analysis$subset2 <- analysis$subset
analysis$subset2[is.na(analysis$foodinsecure)] <- F
analysis$subset2[analysis$excludecov] <- F

#########################################################################################
################ Consider excluding alc use due to high missing #########################
#########################################################################################
analysis$subset3 <- analysis$subset

analysis$excludecov2 <- NA
analysis$excludecov2 <- apply(analysis[, c('Gender', 'Race', 'Education', 'Income', 
                                           'ModerateActivity', 'smoker', 'ridageyr')],
                             MARGIN = 1, function(x) any(is.na(x)))

# check 
table(analysis$excludecov2) #7355 excluded
sapply(analysis[, c('Gender', 'Race', 'Education', 'Income', 'ModerateActivity', 
                    'smoker', 'ridageyr')], function(x) sum(is.na(x)));


## exclude those missing exposure and covariate info
analysis$subset3[is.na(analysis$foodinsecure)] <- F
analysis$subset3[analysis$excludecov2] <- F

# save analysis dataset
save(analysis, file = '~/Repositories/Data/Capstone/analysis.rda')
