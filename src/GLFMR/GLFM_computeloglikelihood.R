
#'@description This function calculates the log-lik of
#' the held-out data in the GLFM. The function uses the trained
#' parameters,
#' to calculate the PDF at the points of missing values, using the true values.
#' Inputs:
#'@param data is a list with X and C
#'@param X: N*D data matrix X
#'@param C: 1xD string with data types, D = number of dimensions
#'@param hidden is a list that contains Z and B
#'@param params contains the other parameters

GLFM_computeloglikelihood<-function(data,hidden,params){
  
  source("pdf_functions/pdf_g.R")
  source("pdf_p.R")
  source("pdf_functions/pdf_n.R")
  source("pdf_functions/pdf_c.R")
  source("pdf_functions/pdf_o.R")
  source("df_p_1.R")
  Zp<-hidden$Z
  P <- dim(Zp)[1]
  K <-dim(hidden$B[[1]])[1]
  #readline("press return to continue")
  if(dim(Zp)[2]!= K){
    stop('Incongruent sizes between Zp and hidden.B: number of latent variables should not be different')
  }
  D <- dim(data$X)[2]
  N <- dim(data$X)[1]
  Z_p <-hidden$Z
  # Deals with missing values
  idx_missing<-which(is.nan(data$X))
  X_aux<-data$X
  aa<-max(X_aux)
  X_aux[idx_missing] <- aa+1
  V_offset<-colMins(X_aux)
  V_offset_mat<-matrix(V_offset,nrow=N,ncol=D,byrow=TRUE)
  X_aux<-data$X-V_offset_mat+1
  idx_catord<-which(data$C=='c' | data$C=='o')
  if(length(idx_catord)>0){
    data$X[,idx_catord] <-X_aux[,idx_catord]
    bu<-apply(X_aux[,idx_catord,drop=FALSE], 2, function(x)length(unique(x)))
    idx_dat<-which(colMaxs(X_aux[,idx_catord,drop=FALSE])!=bu)
    if(length(idx_dat)>0){
      for(ii in 1:length(idx_dat)){
        idxs_bad<-which(X_aux[,idx_dat[ii]]>bu[idx_dat[ii]])
        while(length(idxs_bad)>0){
          X_aux[idxs_bad,idx_dat[ii]]<-X_aux[idxs_bad,idx_dat[ii]]-1
          idxs_bad<-which(X_aux[,idx_dat[ii]]>bu[idx_dat[ii]])
        }
      }
    }
    data$X[,idx_catord]<-X_aux[,idx_catord]
  
# if there is an external transformation change type of dimension d by external data type
    if( "transf_dummie" %in% names(params)){
      if(params$transf_dummie){
        if(is.list(params$t_1)==FALSE){
          data$X[,params$idx_transform]<-params$t_1(data$X[,params$idx_transform])
          data$C[params$idx_transform] <-params$ext_datatype
        }else{
          for(jj in 1:length(params$t_1)){
            data$X[,params$idx_transform[[jj]]]<-params$t_1[[jj]](data$X[,params$idx_transform[[jj]]])
            data$C[params$idx_transform[[jj]]] <-params$ext_datatype[[jj]]
          }
        }
      }
    }
  #Find coordinates of missing values (NaN's are considered as missing)
  X_true <-data$X
  idxs_nonnans<-which(!is.nan(X_true), arr.in=TRUE)
  # Gives the number of non-missing entries:
 rowsnum<-dim(idxs_nonnans)[1]
 lik<-rep(0,rowsnum)
    for(ell in 1:rowsnum){
      n_idx = idxs_nonnans[ell,][1]
      d_idx = idxs_nonnans[ell,][2]
      print(c(n_idx,d_idx,ell))
      print(data$C[d_idx])
      xd = X_true[n_idx,d_idx]
      switch(data$C[d_idx],'g'={lik[ell]<-pdf_g(xd,Zp[n_idx,],hidden$B[[d_idx]],hidden$mu[d_idx],hidden$w[d_idx],hidden$s2y[d_idx],params)},
             'p'={
               lik[ell]<-pdf_p(xd,Zp[n_idx,],hidden$B[[d_idx]],hidden$mu[d_idx],hidden$w[d_idx],hidden$s2y[d_idx])},
             'n'={lik[ell]<-pdf_n(xd,Zp[n_idx,],hidden$B[[d_idx]],hidden$mu[d_idx],hidden$w[d_idx],hidden$s2y[d_idx],params)},
             'c'={lik[ell]<-pdf_c(Zp[n_idx,],hidden$B[[d_idx]],hidden$s2y[d_idx])},
             'o'={lik[ell]<-pdf_o(Zp[n_idx,],hidden$B[[d_idx]],hidden$theta[d_idx,1:(hidden$R[d_idx]-1)],hidden$s2y[d_idx])},
             stop('Unknown data type'))
      if(sum(is.nan(lik[ell])) > 0){
        #print(data$C[d_idx])
        stop('Some values are nan!')
      }
      
     if("transf_dummie" %in% names(params)){
       if(is.list(params$t_1)==FALSE){
       if(params$transf_dummie && d_idx %in% params$idx_transform){
          xd <- params$t_inv(xd)
          lik[ell]<-lik[ell]*abs(params$dt_1(xd))
       }
      }
        # else{
        #    for(kk in 1:length(params$t_1)){
        #     if(d_idx %in% params$idx_transform[[kk]]){
        #         xd <- params$t_inv[[kk]](xd)
        #        lik[ell]<-lik[ell]*abs(params$dt_1[[kk]](xd)))
        #       }
        #     }
        #   }
        }
     lik[ell] <-log(lik[ell]) 
  }
 return(lik) 

  }}