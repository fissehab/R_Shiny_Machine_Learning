

feature_mapping = function(df){
  new_data = c()
  
  for(i in 1:6){
    for(j in 0:i){
      temp = (df$Test1)^i+(df$Test2)^(i-j)
      new_data = cbind(new_data,temp)
    }
  }
  
  colnames(new_data) = paste0("V",1:ncol(new_data))
  new_data
}