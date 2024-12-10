# function from dsr package (no longer supported on R version >4.4)
dsr <- function(data, event, fu, subgroup, ..., refdata, mp, method="normal", sig=0.95, decimals ) {
  
  subgroup <- enquo(subgroup)
  event <- enquo(event)
  fu <- enquo(fu)
  stdvars <- quos(...)
  
  
  
  #Compute crude and standardized rates and variances
  all_data_st = data %>%
    left_join(refdata) %>%
    group_by(!!subgroup) %>%
    mutate(n=sum(!!event),
           d=sum(!!fu),
           cr_rate=n/d,
           cr_var=n/d^2,
           wts=pop/sum(pop),
           st_rate=sum(wts*(!!event/!!fu)),
           st_var=sum(as.numeric((wts^2)*(!!event/(!!fu )^2)))) %>%
    distinct(!!subgroup, .keep_all=TRUE) %>%
    select(!!subgroup, n, d, cr_rate, cr_var, st_rate, st_var)
  
  
  
  #Compute Confidence Intervals (CI) according to method. The default is 'normal'
  if(method=="gamma") {
    
    tmp1 =   all_data_st %>%
      mutate(
        c_rate=mp*cr_rate,
        c_lower=mp*qgamma((1-sig)/2, shape=cr_rate^2/(cr_var))/(cr_rate/cr_var),
        c_upper=mp*qgamma(1-((1-sig)/2), shape=1+cr_rate^2/(cr_var))/(cr_rate/cr_var),
        s_rate=mp*st_rate,
        s_lower=mp*qgamma((1-sig)/2, shape=st_rate^2/st_var)/(st_rate/st_var),
        s_upper=mp*qgamma(1-((1-sig)/2), shape=1+(st_rate^2/st_var))/(st_rate/st_var)) %>%
      select(!!subgroup, n, d, c_rate, c_lower, c_upper, s_rate, s_lower, s_upper)
    
    
  } else if (method=="normal") {
    
    
    tmp1 =   all_data_st %>%
      mutate(
        c_rate=mp*cr_rate,
        c_lower=mp*(cr_rate+qnorm((1-sig)/2)*sqrt(cr_var)),
        c_upper=mp*(cr_rate-qnorm((1-sig)/2)*sqrt(cr_var)),
        s_rate=mp*st_rate,
        s_lower=mp*(st_rate+qnorm((1-sig)/2)*sqrt(st_var)),
        s_upper=mp*(st_rate-qnorm((1-sig)/2)*sqrt(st_var))) %>%
      select(!!subgroup, n, d, c_rate, c_lower, c_upper, s_rate, s_lower, s_upper)
    
  } else if (method=="lognormal") {
    
    
    tmp1 =   all_data_st %>%
      mutate(
        c_rate=mp*cr_rate,
        c_lower=mp*exp((log(cr_rate)+qnorm((1-sig)/2)*sqrt(cr_var)/(cr_rate))),
        c_upper=mp*exp((log(cr_rate)-qnorm((1-sig)/2)*sqrt(cr_var)/(cr_rate))),
        s_rate=mp*st_rate,
        s_lower=mp*exp((log(st_rate)+qnorm((1-sig)/2)*sqrt(st_var)/(st_rate))),
        s_upper=mp*exp((log(st_rate)-qnorm((1-sig)/2)*sqrt(st_var)/(st_rate)))) %>%
      select(!!subgroup, n, d, c_rate, c_lower, c_upper, s_rate, s_lower, s_upper)
    
  }
  
  
  #Clean up and output
  
  tmp1$c_rate  <- round(tmp1$c_rate,  digits=decimals)
  tmp1$c_lower <- round(tmp1$c_lower, digits=decimals)
  tmp1$c_upper <- round(tmp1$c_upper, digits=decimals)
  tmp1$s_rate  <- round(tmp1$s_rate, digits=decimals)
  tmp1$s_lower <- round(tmp1$s_lower, digits=decimals)
  tmp1$s_upper <- round(tmp1$s_upper, digits=decimals)
  
  colnames(tmp1) <-  c('Subgroup', 'Numerator','Denominator',
                       paste('Crude Rate (per ',mp,')',sep=''),
                       paste(sig*100,'% LCL (Crude)',sep=''),
                       paste(sig*100,'% UCL (Crude)',sep=''),
                       paste('Std Rate (per ',mp,')',sep=''),
                       paste(sig*100,'% LCL (Std)',sep=''),
                       paste(sig*100,'% UCL (Std)',sep=''))
  
  
  tmp1 <- as.data.frame(tmp1)
  
}
