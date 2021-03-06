Table1Weighted <- function(rowvars, colvariable, design) {
  data <- design$variables[0,]
  if (!is.atomic(rowvars)) stop("Please pass row variables as a vector")
  if (length(unique(data[,colvariable])) > 20) 
    stop("Column Variable has more than 20 unique values,please pass a column variable with less than 20 unique values")
  if (!is.factor(data[,colvariable])) data[,colvariable] <- factor(data[,colvariable])
  #set column names
  Col_n <- svytable(as.formula(paste0("~", colvariable)), design, round = T)
  cnames <- c(paste0(levels(data[,colvariable]),"\\newline (n= ", format(Col_n, big.mark = ',', trim = T), ")"), 'p-value')
  # coln <- c(paste(" (n= ", format(Col_n, big.mark = ',', trim = T)
  #                , ")", sep = ''), " ")
  
  
  #col dimensions
  col_dim <- length(levels(data[,colvariable]))
  
  #determine row types and names
  vartypes <- lapply(rowvars, function(i){is.factor(data[,i])})
  catvars <- rowvars[vartypes == T]
  numlevels <- lapply(catvars, function(i){length(levels(data[,i]))})
  binaryvars <- catvars[numlevels == 2]
  binarylabs <- unlist(lapply(binaryvars, function(i){
    if (is.numeric(i)) title <- names(data)[i]
    else title <- i
    lab <- c(title,paste("\\  ",levels(data[,i])[2], sep = ''))
    return(lab)
    }))
  nonbinary <- catvars[!(numlevels == 2)]
  nonbinlab <- unlist(lapply(nonbinary, function(x){
    if (is.numeric(x)) title <- names(data)[x]
    else title <- x
    lab <- c(title,paste("\\  ",levels(data[,x]), sep = ''))
    return(lab)
    }))
   
  contvars <- rowvars[vartypes == F]
  if (is.numeric(contvars)) continuous_labels <- unlist(lapply(contvars, function(i){names(data)[i]}))
  else continuous_labels <- contvars
  rnames <- c(" ", binarylabs, nonbinlab," ",continuous_labels) 

  #function to return row for binary categorical variables
  returnRowBin <- function(var){
    n <- svytable(as.formula(paste0("~", var, ' + ', colvariable)), design, 
                  round = T)
    percent <- round(n[2,]/apply(n,2,sum)*100, digits = 0)
    n_per <- c(paste(format(n[2,], big.mark = ',', trim = T), 
                     "(", percent, ")", sep = ''), '')
    p <- summary(n)$statistic$p.value
    if (p < 0.01) p <- '<0.01'
    else p <- sprintf('%.2f',p)
    returnRow <- matrix(c(replicate(col_dim,""),p, n_per),nrow = 2, byrow = T)
    return(returnRow)
  }
  
  returnRowNonBin <- function(var){
    levs <- length(levels(data[,var]))
    n <- svytable(as.formula(paste0("~", var, ' + ', colvariable)), design, 
                  round = T)
    s <- apply(n,2,sum)
    percent <- round(sapply(1:col_dim, function(i) n[,i]/s[i]*100), 0)
    p <- summary(n)$statistic$p.value
    if (p < 0.01) p <- '<0.01'
    else p <- sprintf('%.2f',p)
    n_per <- cbind(matrix(paste(format(n, big.mark = ',', trim = T), 
                                "(", percent, ")", sep = ''),nrow = levs, 
                          byrow = F), replicate(levs,""))
    returnRow <- rbind(c(replicate(col_dim,""), p), n_per)
    return(returnRow)
  }
  
  returnRowContinuous <- function(var){
    summ <- svyby(formula = as.formula(paste0("~", var)),
                  by = as.formula(paste0("~", colvariable)), 
                  FUN = svymean, design = design)
    if (summ[1,2] >= 10) m_sd <- paste(round(summ[,2],digits=0),"(",
                                       sprintf('%.1f',summ[,3]),")",sep = '')
    else if (summ[1,2] >= 1) m_sd <- paste(sprintf('%.1f',summ[,2]),"(",
                                           sprintf('%.2f',summ[,3]),")",sep = '')
    else if (summ[1,2] >= 0.1) m_sd <- paste(sprintf('%.2f',summ[,2]),"(",
                                             sprintf('%.3f',summ[,3]),")",sep = '')
    else if (summ[1,2] >= 0.01) m_sd <- paste(sprintf('%.2e',summ[,2]),"(",
                                              sprintf('%.2e',summ[,3]),")",sep = '')
    p <- summary(svyglm(as.formula(paste0(colvariable, "~", var)),
                                design = design, 
                        family = 'quasibinomial'))$coefficients[2,4]
    if (p < 0.01) p <- '<0.01'
    else p <- sprintf('%.2f',p)
    returnRow <- matrix(c(m_sd, p),nrow = 1, byrow = T)
    return(returnRow)
  }
  
  #put together table
  cattable <- do.call(rbind, lapply(c(lapply(binaryvars, returnRowBin),
                                      lapply(nonbinary, returnRowNonBin)),
                                    data.frame, stringsAsFactors=FALSE))
  conttable <- do.call(rbind, lapply(lapply(contvars, returnRowContinuous),
                                     data.frame, stringsAsFactors=FALSE))
  finaltab <- as.matrix(rbind.data.frame(c(replicate(col_dim,"N(%)"), ''), 
                                         cattable,c(replicate(col_dim,"Mean(SD)"),
                                                    ''),
                                         conttable,
                                         make.row.names = F,
                                         stringsAsFactors = F))
  dimnames(finaltab) <- list(rnames,cnames)
  return(finaltab)
  
}


