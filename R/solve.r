
.sm_compile_model <- function(obj, 
   tmp.dir = NULL, tmp.del = FALSE, ...) {
  read_default_data <- function(prec, ss) {
    for(i in seq(along = prec@parameters)) {
      if (any(prec@parameters[[i]]@colName != '')) {
        prec@parameters[[i]]@defVal <-
          as.numeric(ss@defVal[1, prec@parameters[[i]]@colName])
        prec@parameters[[i]]@interpolation <-
          as.character(ss@interpolation[1, prec@parameters[[i]]@colName])
      }
    }
    prec
  }
  check_parameters <- function(prec) {
    error_type <- c()
    # Check that lo bound less or equal up bound
    for(pr in names(prec@parameters)[sapply(prec@parameters,
      function(x) x@type == 'double')]) 
        if (nrow(prec@parameters[[pr]]@data) > 0 && prec@parameters[[pr]]@nValues != 0) {
      if (prec@parameters[[pr]]@nValues != -1)  
        prec@parameters[[pr]]@data <- prec@parameters[[pr]]@data[seq(length.out = 
          prec@parameters[[pr]]@nValues),, drop = FALSE]
      gg <- prec@parameters[[pr]]@data
      fl <- gg[gg$type == 'lo', 'value'] > gg[gg$type == 'up', 'value']
      stopifnot(all(gg[gg$type == 'lo', 0:1 - ncol(gg)] ==
          gg[gg$type == 'up', 0:1 - ncol(gg)]))
      if (any(fl)) {
        error_type <- c(error_type, pr)
        cat('Error: Unexcaptable bound value (up bound less lo bound) "',
          pr, '":\n', sep = '')
        invisible(apply(gg[gg$type == 'lo', 0:1 - ncol(gg)][fl, ], 1, function(x)
          cat(paste(x, collapse = '.'), '\n')))
      }
    }
    if (length(error_type)) stop('Unexcaptable bound value (up bound less lo bound) "',
      paste(error_type, collapse = '", "'), '"')
    shr <- prec@parameters$pTechShare@data
  #  # Check sum share.lo <= 1 and sum share.up >= 1
    if (nrow(shr) > 0) {
    FL <- FALSE
    p1 <- proc.time()[3]
      # Devide commodity by technology/group/inp&out
      inp_comm <- prec@parameters$mTechInpComm@data
      out_comm <- prec@parameters$mTechOutComm@data
      group_comm <- prec@parameters$mTechGroupComm@data
      inp_comm[, 'als'] <- 'input'
      out_comm[, 'als'] <- 'output'
      shr <- merge(merge(shr, group_comm), rbind(inp_comm, out_comm))
      # Check and out
      hh <- tapply(shr$value, shr[, c('type', 'tech', 'als', 'group', 'region', 'year', 'slice')], sum)
      if (max(hh['lo',,,,,,], na.rm = TRUE) > 1) {
        FL <- TRUE
        ll <- apply(hh['lo',,,,,,, drop = FALSE], 2:7, sum); ll[is.na(ll)] <- 0
        tec <- dimnames(ll)[[1]][apply(ll > 1, 1, any)]
        for(tt in tec) {
          al <- dimnames(ll)[[2]][apply(ll[tt,,,,,, drop = FALSE] > 1, 2, any)]
          for(a in al) {
            gr <- dimnames(ll)[[3]][apply(ll[tt, a,,,,, drop = FALSE] > 1, 2, any)]
            for(g in gr) {
              if (length(unique(ll[tt, a, g,,,])) == 1) {
                #cat('', tt, a, g, '\n')
                cat('Share lo more than 1 for ', a, ' commodity: ', tt, '.',
                   g, '.*.*.*', ' ', ll[tt, a, g, 1, 1, ], '\n', sep = '')
              }  else {
                rg <- dimnames(ll)[[4]][apply(ll[tt, a, g,,,, drop = FALSE] > 1, 
                  4, any)][1]
                yr <- dimnames(ll)[[5]][apply(ll[tt, a, g, rg,,, drop = FALSE] > 1, 
                  5, any)][1]
                sl <- dimnames(ll)[[6]][apply(ll[tt, a, g, rg, yr,, drop = FALSE] > 1, 
                  6, any)][1]
                cat('Share lo more than 1 for ', a, ' commodity, first row: ', tt, '.',
                   g, '.', rg, '.', yr, '.', sl, ' ', ll[tt, a, g, rg, yr, sl], 
                     '\n', sep = '')
                }
              }
            }
          }
        }
      if (min(hh['up',,,,,,], na.rm = TRUE) < 1) {
        FL <- TRUE
        ll <- apply(hh['up',,,,,,, drop = FALSE], 2:7, sum); ll[is.na(ll)] <- 1
        tec <- dimnames(ll)[[1]][apply(ll < 1, 1, any)]
        for(tt in tec) {
          al <- dimnames(ll)[[2]][apply(ll[tt,,,,,, drop = FALSE] < 1, 2, any)]
          for(a in al) {
            gr <- dimnames(ll)[[3]][apply(ll[tt, a,,,,, drop = FALSE] < 1, 2, any)]
            for(g in gr) {
              if (length(unique(ll[tt, a, g,,,])) == 1) {
                #cat('', tt, a, g, '\n')
                cat('Share up less than 1 for ', a, ' commodity: ', tt, '.',
                   g, '.*.*.*', ' ', ll[tt, a, g, 1, 1, ], '\n', sep = '')
              }  else {
                rg <- dimnames(ll)[[4]][apply(ll[tt, a, g,,,, drop = FALSE] < 1, 
                  4, any)][1]
                yr <- dimnames(ll)[[5]][apply(ll[tt, a, g, rg,,, drop = FALSE] < 1, 
                  5, any)][1]
                sl <- dimnames(ll)[[6]][apply(ll[tt, a, g, rg, yr,, drop = FALSE] < 1, 
                  6, any)][1]
                cat('Share up less than 1 for ', a, ' commodity, first row: ', tt, '.',
                   g, '.', rg, '.', yr, '.', sl, ' ', ll[tt, a, g, rg, yr, sl], 
                     '\n', sep = '')
                }
              }
            }
          }
        }
      if (FL) stop('Unexceptable share parameter')
    }
  }
#####################################################################################
# Argument data prepare
#####################################################################################
  pp1 <- proc.time()[3]
  # Upper case
  arg <- list(...)
  if (any(names(arg) == 'exclude')) arg <- arg[!(names(arg) %in% c('exclude', arg$exclude))]
  if (any(names(arg) == 'solver')) {
    solver <- arg$solver
    arg <- arg[names(arg) != 'solver', drop = FALSE]
  } else solver <- 'GAMS'
  if (solver == 'GAMS') {
    rs <- try(system('gams'))
    if (rs != 0) stop('There is no gams')
  }
  if (is.null(tmp.dir)) {
    tmp.dir <- getwd()
  }
  if (any(names(arg) == 'n.threads')) {
    n.threads <- arg$n.threads
    arg <- arg[names(arg) != 'n.threads', drop = FALSE]
  } else n.threads <- detectCores()
#    if (.Platform$OS.type == "unix") {
#      tmpdir = Sys.getenv('TMPDIR')
#    } else {
#       tmpdir = Sys.getenv('TMP')
#    }
    tmp.dir <-  paste(tmp.dir, '/solwork/', sep = '')
    add_drr <- paste(solver, obj@name, format(Sys.Date(),
       format = '%Y-%m-%d'), format(Sys.time(), format = '%H-%M-%S'), sep = '_')
    #dir.create(paste(tmpdir, '/', add_drr, '/', sep = ''), recursive = TRUE)
    tmp.dir <- paste(tmp.dir, '/', add_drr, sep = '')
    dir.create(tmp.dir, recursive = TRUE)
  #}
  tmpdir <- tmp.dir
  BEGINDR <- getwd()
  description <- ''
  if (is.null(names(arg)) || any(names(arg) == '')) stop('Undefined argument')
  if (any(names(arg) == 'scenario')) {
    if (class(arg$scenario) == 'scenario') {
      name <- arg$scenario@name
      description <- arg$scenario@description
      obj@data <- obj@data[sapply(obj@data, function(x) x@name) %in% 
         sapply(arg$scenario@data, function(x) x@name)]
      obj@data <- arg$scenario@model@sysInfo
    } else {
      if (is.null(names(arg$scenario)) || any(names(arg$scenario) == '')) stop('Wrong argument scenario')
      for(i in names(arg$scenario)) 
        arg[[i]] <- arg$scenario[[i]] 
    }
    arg <- arg[names(arg) != 'scenario', drop = FALSE]    
  }
  if (all(names(arg) != 'name')) stop('Name undefined')
  name <- arg$name
  arg <- arg[names(arg) != 'name', drop = FALSE]    
  if (any(names(arg) == 'description')) {
    description <- arg$description
    arg <- arg[names(arg) != 'description', drop = FALSE]    
  }
  if (any(names(arg) == 'model.type')) {
    model.type <- arg$model.type
    arg <- arg[names(arg) != 'model.type', drop = FALSE]
    if (all(model.type != c('reduced', 'full')))
     stop('Unknown model.type argument, have to be "full" or "reduced"')
  } else model.type <- 'reduced'
  if (model.type == 'reduced') {
    if (length(getNames(obj, class = 'constrain', type = '(fixom|varom|actvarom|cvarom|avarom)')) > 0) {
      stop(paste('Unexeptable constrain for reduced model: "', 
        paste(getNames(obj, class = 'constrain', type = '(fixom|varom|actvarom|cvarom|avarom)'), 
          collapse = '", "'), '"', sep = ''))
    }
  }
  if (any(names(arg) == 'region')) {
    obj@sysInfo@region <- arg$region
    arg <- arg[names(arg) != 'region', drop = FALSE]
  } 
  if (any(names(arg) == 'year')) {
    obj@sysInfo@year <- arg$year
    arg <- arg[names(arg) != 'year', drop = FALSE]
  } 
  if (any(names(arg) == 'slice')) {
    obj@sysInfo@slice <- arg$slice
    arg <- arg[names(arg) != 'slice', drop = FALSE]
  } 
  if (any(names(arg) == 'repository')) {
    rpp <- sapply(obj@data, function(x) x@name)
    if (any(!(arg$repository %in% rpp))) stop('Undefined repository ', 
                                  arg$repository[!(arg$repository %in% rpp)]) 
    obj@data <- obj@data[rpp %in% arg$repository]
    arg <- arg[names(arg) != 'repository', drop = FALSE]
  }
  if (any(names(arg) == 'glpkCompileParameter')) {
    glpkCompileParameter <- arg$glpkCompileParameter
    arg <- arg[names(arg) != 'glpkCompileParameter', drop = FALSE]
  } else glpkCompileParameter <- ''
  if (any(names(arg) == 'gamsCompileParameter')) {
    gamsCompileParameter <- arg$gamsCompileParameter
    arg <- arg[names(arg) != 'gamsCompileParameter', drop = FALSE]
  } else gamsCompileParameter <- ''
  if (any(names(arg) == 'cbcCompileParameter')) {
    cbcCompileParameter <- arg$cbcCompileParameter
    arg <- arg[names(arg) != 'cbcCompileParameter', drop = FALSE]
  } else cbcCompileParameter <- ''
  if (any(names(arg) == 'echo')) {
    echo <- arg$echo
    arg <- arg[names(arg) != 'echo', drop = FALSE]
  } else echo <- TRUE
  if (any(names(arg) == 'show.output.on.console')) {
    show.output.on.console <- arg$show.output.on.console
    arg <- arg[names(arg) != 'show.output.on.console', drop = FALSE]
  } else show.output.on.console <- TRUE
  if (any(names(arg) == 'invisible')) {
    arg_invisible <- arg$invisible
    arg <- arg[names(arg) != 'invisible', drop = FALSE]
  } else arg_invisible <- TRUE
#####################################################################################
# Fill data to Code produce
#####################################################################################
  if (nrow(obj@sysInfo@milestone) == 0) {
    if (!all(min(obj@sysInfo@year) + seq(along = obj@sysInfo@year) - 1 == obj@sysInfo@year))
      stop('wrong year, use setMilestoneYears function')
    obj <- setMilestoneYears(obj, start = min(obj@sysInfo@year), interval = rep(1, length(obj@sysInfo@year)))
  }
  # Create exemplar for code
  prec <- new('modInp')
  # List for approximation
  approxim <- list(
      region = obj@sysInfo@region,
      year   = obj@sysInfo@year,
      slice  = obj@sysInfo@slice
  )
  if (any(names(arg) == 'region')) {
      approxim$region = arg$region
      obj@sysInfo@region <- arg$region
      arg <- arg[names(arg) != 'region', drop = FALSE]
  }
  if (any(names(arg) == 'year')) {
      approxim$year = arg$year
      obj@sysInfo@year <- arg$year
      arg <- arg[names(arg) != 'year', drop = FALSE]
  }
  if (any(names(arg) == 'slice')) {
      approxim$slice = arg$slice
      obj@sysInfo@slice <- arg$slice
      arg <- arg[names(arg) != 'slice', drop = FALSE]
  }
  if (any(names(arg) == 'discount')) {
      obj@sysInfo@discount <- arg$discount
      arg <- arg[names(arg) != 'discount', drop = FALSE]
  }
  if (any(names(arg) == 'repository')) {
      obj@data <- obj@data[sapply(obj@data, function(x) x@name %in% arg@repository)]
      arg <- arg[names(arg) != 'repository', drop = FALSE]
  }
  if (any(names(arg) == 'open.folder')) {
      open.folder <- arg$open.folder
      arg <- arg[names(arg) != 'open.folder', drop = FALSE]
  } else open.folder <- FALSE
  # Fill DB by region & slice
  for(i in c('region', 'slice')) {
    prec@parameters[[i]] <- addData(prec@parameters[[i]], approxim[[i]])
  }
  # Fill DB by year
  prec@parameters[['year']] <- addData(prec@parameters[['year']], as.numeric(approxim[['year']]))
  prec <- read_default_data(prec, obj@sysInfo)
  # add set 
  for(i in seq(along = obj@data)) {
        for(j in seq(along = obj@data[[i]]@data)) { #if (class(obj@data[[i]]@data[[j]]) == 'technology') {
          prec <- add_name(prec, obj@data[[i]]@data[[j]], approxim = approxim)
        }
    }
  cat('Generating model input files ')
  # Fill DB main data
  if (n.threads > 1) {
    prorgess_bar_p <- proc.time()[3]
    tryCatch({
      cl <- makePSOCKcluster(rep('localhost', n.threads))
      ll <- list()
      for(i in seq(along = obj@data)) {
        for(j in seq(along = obj@data[[i]]@data)) { 
          ll[[length(ll) + 1]] <- obj@data[[i]]@data[[j]]
        }
      }
      gg <- lapply(1:n.threads - 1, function(x) ll[(seq(along = ll) - 1) %% n.threads == x])
      prclst <- parLapply(cl, gg, 
        function(ll, prec, approxim) {
            require(energyRt)
            for(i in seq(along = ll)) {
              prec <- add0(prec, ll[[i]], approxim = approxim)
            }
          prec
        }, prec, approxim)
      stopCluster(cl)
    }, interrupt = function(x) {
      stopCluster(cl)
      stop('Solver has been interrupted')
    }, error = function(x) {
      stopCluster(cl)
      stop(x)
    })    
    for(i in names(prec@parameters)) {
        hh <- sapply(prclst, function(x) if (x@parameters[[i]]@nValues == -1) 
          nrow(x@parameters[[i]]@data) else x@parameters[[i]]@nValues)
        if (prec@parameters[[i]]@nValues == -1) nn <- nrow(prec@parameters[[i]]@data) else 
          nn <- prec@parameters[[i]]@nValues
        hh <- hh - nn
        n0 <- nn
        fl <- seq(along = hh)[hh != 0]
        if (length(fl) != 0) {
          prec@parameters[[i]]@data[nn + 1:sum(hh), ] <- NA
          for(j in fl) {
            prec@parameters[[i]]@data[nn + 1:hh[j], ] <- prclst[[j]]@parameters[[i]]@data[n0 + 1:hh[j], ]
            nn <- nn + hh[j]
          }
          if (prec@parameters[[i]]@nValues != -1) prec@parameters[[i]]@nValues <- nn
          if (i == 'group' && nn != 0) {
            if (prec@parameters[[i]]@nValues != -1) {
              gr <- unique(prec@parameters[[i]]@data[seq(length.out = prec@parameters[[i]]@nValues), 1])
              prec@parameters[[i]]@data[, 1] <- NA
              prec@parameters[[i]]@data[1:length(gr), 1] <- gr
              prec@parameters[[i]]@nValues <- length(gr)
            } else {
              gr <- unique(prec@parameters[[i]]@data[, 1])
              prec@parameters[[i]]@data <- prec@parameters[[i]]@data[1:length(gr),, drop = FALSE]
              prec@parameters[[i]]@data[, 1] <- gr
            }
          }
        }
    }
    cat(' ', round(proc.time()[3] - prorgess_bar_p, 2), 's\n')
  } else if (n.threads == 1) {
    prorgess_bar <- sapply(obj@data, function(x) length(x@data))
    if (is.list(prorgess_bar)) prorgess_bar <- 0 else prorgess_bar <- sum(prorgess_bar)
    prorgess_bar_0 <- 0
    prorgess_bar_dl <- (prorgess_bar + 50 - 1) %/% 50
    hh <- sum(sapply(obj@data, function(x) length(x@data)))
    k <- 0
      prorgess_bar_p <- proc.time()[3]
    # Fill DB main data
      for(i in seq(along = obj@data)) {
          for(j in seq(along = obj@data[[i]]@data)) { 
            k <- k + 1
            hh[k] <- proc.time()[3]
            prec <- add0(prec, obj@data[[i]]@data[[j]], approxim = approxim)
            hh[k] <- hh[k] - proc.time()[3]
            prorgess_bar_0 <- prorgess_bar_0 + 1
            if (prorgess_bar_0 %% prorgess_bar_dl == 0) {
              cat('.')
              flush.console() 
            }
          }
      }
      cat(' ', round(proc.time()[3] - prorgess_bar_p, 2), 's\n')
  } else stop('Uneceptable threads number')
  prec <- add0(prec, obj@sysInfo, approxim = approxim) 
#    for(i in seq(along = prec@parameters)) {
#      if (prec@parameters[[i]]@nValues != 0) {
#          prec@parameters[[i]]@data <- prec@parameters[[i]]@data[1:prec@parameters[[i]]@nValues,, drop = FALSE]
#      }
#    }
#####################################################################################
# Handle data
#####################################################################################
  # Check slots
  check_set <- function(set, alias = NULL) {
    if (is.null(alias)) alias <- set
    ss <- prec@parameters[[set]]@data[, set]
    for(al in alias) {
      for(i in 1:length(prec@parameters)) {
        if (any(prec@parameters[[i]]@dimSetNames == al) 
            && !all(getSet(prec@parameters[[i]], al) %in% ss)) {
              dd <- getSet(prec@parameters[[i]], al)[!(getSet(prec@parameters[[i]], al) %in% ss)]
              dd <- prec@parameters[[i]]@data[prec@parameters[[i]]@data[, set] %in% dd, , drop = FALSE]
              stop(paste('Unknown ', set, ' in slot ', prec@parameters[[i]]@name, '\n', 
                paste(apply(dd, 1, function(x) paste(x, collapse = '.')), collapse = '\n'), 
                '\n', sep = ''))               
        }
      }
    }
  }
  # Additional for compatibility with GLPK
  check_set('comm', c('comm', 'commp', 'acomm'))
  for(i in c('expp', 'imp', 'tech', 'trade', 'sup', 'group', 'region', 'year', 'slice')) check_set(i)
  if (length(obj@LECdata) != 0) {
     prec@parameters$mLECRegion <- addMultipleSet(prec@parameters$mLECRegion, obj@LECdata$region)
     if (length(obj@LECdata$pLECLoACT) == 1) {
        prec@parameters$pLECLoACT <- addData(prec@parameters$pLECLoACT, 
            data.frame(region = obj@LECdata$region, value = obj@LECdata$pLECLoACT))
     }
  }
  ## Constrain
  yy <- c('tech', 'sup', 'stg', 'expp', 'imp', 'trade', 'group', 'comm', 'region', 'year', 'slice')
  appr <- lapply(yy, function(x) prec@parameters[[x]]@data[[x]])
  names(appr) <- yy
  appr$group <- appr$group[!is.na(appr$group)]
  # ---------------------------------------------------------------------------------------------------------  
# Fix to previous data
# ---------------------------------------------------------------------------------------------------------  
  if (any(names(arg) == 'fix_data')) {
      ll <- c("vTechUse", "vTechNewCap", "vTechRetiredCap",# "vTechRetrofitCap", "vTechUpgradeCap", 
              "vTechCap", "vTechAct", 
              "vTechInp", "vTechOut", "vTechAInp", "vTechAOut", "vSupOut", 
              "vDemInp", "vDummyImport", "vDummyExport", "vStorageInp", "vStorageOut", "vStorageStore", "vStorageCap", 
              "vStorageNewCap", "vImport", "vExport", "vTradeFlow", "vExportRow", "vImportRow")
      if (!is.character(arg$fix_data) || any(!(arg$fix_data %in% c('all', ll)))) {
        if (!is.character(arg$fix_data)) stop('Uncorrect fix_data') else
          stop('Unknown fix_data ', paste(arg$fix_data[!(arg$fix_data %in% c('all', ll))], collapse = ', '))
      }
      if (any(arg$fix_data == 'all') && length(arg$fix_data) != 1) 
        stop('Value all and other one is prohibited fix_data')
      if (arg$fix_data != 'all') ll <- ll[ll %in% arg$fix_data]
      for(i in ll) {
        p1 <- proc.time()[3]
        gg <- as.data.frame.table(arg$fix_scenario@result@data[[i]], stringsAsFactors = FALSE)
        for(j in seq(length.out = ncol(gg) - 1)) {
          k <- gsub('[.].*', '', colnames(gg)[j])
          gg <- gg[gg[, j] %in% appr[[k]],, drop = FALSE]
          if (k == 'year') {
            gg <- gg[gg[, j] %in% arg$fix_year,, drop = FALSE]
            gg[, j] <- as.numeric(gg[, j])
          }
        }
        colnames(gg) <- gsub('[.]1', 'p', colnames(gg))
        colnames(gg) <- gsub('[.]2', 'e', colnames(gg))
        prec@parameters[[gsub('^.', 'mPreDef', i)]] <- 
           addData(prec@parameters[[gsub('^.', 'mPreDef', i)]], gg[, -ncol(gg)])
        gg <- gg[gg[, 'value'] != 0,] 
        prec@parameters[[gsub('^.', 'preDef', i)]] <- addData(prec@parameters[[gsub('^.', 'preDef', i)]], gg)
      
      }
      arg <- arg[names(arg) != 'fix_data', drop = FALSE]
      arg <- arg[names(arg) != 'fix_scenario', drop = FALSE]
      arg <- arg[names(arg) != 'fix_year', drop = FALSE]
  }
# ---------------------------------------------------------------------------------------------------------  
# Get only listing file
# ---------------------------------------------------------------------------------------------------------  
  if (any(names(arg) == 'only.listing')) {
      only.listing <- arg$only.listing
      if (only.listing && solver != 'GAMS') {
         stop('only.listing file have to be only with GAMS "solver"')
      }
      arg <- arg[names(arg) != 'only.listing', drop = FALSE]
  } else only.listing <- FALSE
  
  if (length(arg) != 0) warning('Unknown argument ', names(arg))
# ---------------------------------------------------------------------------------------------------------  
      gg <- prec@parameters[['pDiscount']]@data
      gg <- gg[sort(gg$year, index.return = TRUE)$ix,, drop = FALSE]
      ll <- gg[0,, drop = FALSE]
      for(l in unique(gg$region)) {
        dd <- gg[gg$region == l,, drop = FALSE]
        dd$value <- cumprod(1 / (1 + dd$value))
        ll <- rbind(ll, dd)
      }
      prec@parameters[['pDiscountFactor']] <- addData(prec@parameters[['pDiscountFactor']], ll)
       hh <- gg[gg$year == as.character(max(obj@sysInfo@year)), -2]
       hh <- hh[hh$value == 0, 'region', drop = FALSE]
      # Add mDiscountZero - zero discount rate in final period
      if (nrow(hh) != 0) {
        prec@parameters[['mDiscountZero']] <- addData(prec@parameters[['mDiscountZero']], hh)
      } 
LL1 <- proc.time()[3]
      ##!!!!!!!!!!!!!!!!!!!!!
      # Add defpSupReserve
      gg <- getParameterData(prec@parameters[['pSupReserve']])
#      if (prec@parameters[['pSupReserve']]@nValues != -1)
#        gg <- gg[seq(length.out = prec@parameters[['pSupReserve']]@nValues),, drop = FALSE]
      gg <- gg[gg$value != Inf, ]
      if (nrow(gg) != 0) {
        prec@parameters[['defpSupReserve']] <- 
          addData(prec@parameters[['defpSupReserve']], gg[, 1:(ncol(gg) - 1), drop = FALSE])
      } else if (nrow(gg) == 0 && prec@parameters[['pSupReserve']]@defVal == Inf) {
        prec@parameters[['defpSupReserve']]@defVal <- 0
      }  else prec@parameters[['defpSupReserve']]@defVal <- 1
      # Add defpSupAvaUp
      gg <- getParameterData(prec@parameters[['pSupAva']])
#      if (prec@parameters[['pSupAva']]@nValues != -1)
#        gg <- gg[seq(length.out = prec@parameters[['pSupAva']]@nValues),, drop = FALSE]
      gg <- gg[gg$value != Inf & gg$type == 'up', ]
      if (nrow(gg) != 0) {
        prec@parameters[['defpSupAvaUp']] <- addData(prec@parameters[['defpSupAvaUp']], 
           gg[, 1:(ncol(gg) - 2), drop = FALSE])
      } else if (nrow(gg) == 0 && prec@parameters[['pSupAva']]@defVal == Inf) {
        prec@parameters[['defpSupAvaUp']]@defVal <- 0
      }  else prec@parameters[['defpSupAvaUp']]@defVal <- 1
      # Add pDummyImportCost
      gg <- getParameterData(prec@parameters[['pDummyImportCost']])
      gg <- gg[gg$value != Inf, ]
      if (nrow(gg) != 0) {
        prec@parameters[['defpDummyImportCost']] <- 
          addData(prec@parameters[['defpDummyImportCost']], gg[, 1:(ncol(gg) - 1), drop = FALSE])
      } else if (nrow(gg) == 0 && prec@parameters[['pDummyImportCost']]@defVal == Inf) {
        prec@parameters[['defpDummyImportCost']]@defVal <- 0
      } else prec@parameters[['defpDummyImportCost']]@defVal <- 1
      # Add pDummyExportCost
      gg <- getParameterData(prec@parameters[['pDummyExportCost']])
      gg <- gg[gg$value != Inf, ]
      if (nrow(gg) != 0) {
        prec@parameters[['defpDummyExportCost']] <- 
          addData(prec@parameters[['defpDummyExportCost']], gg[, 1:(ncol(gg) - 1), drop = FALSE])
      } else if (nrow(gg) == 0 && prec@parameters[['pDummyExportCost']]@defVal == Inf) {
        prec@parameters[['defpDummyExportCost']]@defVal <- 0
      } else prec@parameters[['defpDummyExportCost']]@defVal <- 1
      # defpExportRowRes   
      gg <- getParameterData(prec@parameters[['pExportRowRes']])
#      if (prec@parameters[['pExportRowRes']]@nValues != -1)
#        gg <- gg[seq(length.out = prec@parameters[['pExportRowRes']]@nValues),, drop = FALSE]
      gg <- gg[gg$value != Inf, ]
      if (nrow(gg) != 0) {
        prec@parameters[['defpExportRowRes']] <- addData(prec@parameters[['defpExportRowRes']], 
          gg[, 1:(ncol(gg) - 1), drop = FALSE])
      } else if (nrow(gg) == 0 && prec@parameters[['pExportRowRes']]@defVal == Inf) {
        prec@parameters[['defpExportRowRes']]@defVal <- 0
      }  else prec@parameters[['defpExportRowRes']]@defVal <- 1
      # defpImportRowRes
      gg <- getParameterData(prec@parameters[['pImportRowRes']])
#      if (prec@parameters[['pImportRowRes']]@nValues != -1)
#        gg <- gg[seq(length.out = prec@parameters[['pImportRowRes']]@nValues),, drop = FALSE]
      gg <- gg[gg$value != Inf, ]
      if (nrow(gg) != 0) {
        prec@parameters[['defpImportRowRes']] <- addData(prec@parameters[['defpImportRowRes']], 
          gg[, 1:(ncol(gg) - 1), drop = FALSE])
      } else if (nrow(gg) == 0 && prec@parameters[['pImportRowRes']]@defVal == Inf) {
        prec@parameters[['defpImportRowRes']]@defVal <- 0
      }  else prec@parameters[['defpImportRowRes']]@defVal <- 1
      # defpExportRowUp 
      gg <- getParameterData(prec@parameters[['pExportRow']])
#      if (prec@parameters[['pExportRow']]@nValues != -1)
#        gg <- gg[seq(length.out = prec@parameters[['pExportRow']]@nValues),, drop = FALSE]
      gg <- gg[gg$type == 'up' & gg$value != Inf, ]
      if (nrow(gg) != 0) {
        prec@parameters[['defpExportRowUp']] <- addData(prec@parameters[['defpExportRowUp']], 
          gg[, 1:(ncol(gg) - 2), drop = FALSE])
      } else if (nrow(gg) == 0 && prec@parameters[['pExportRow']]@defVal[2] == Inf) {
        prec@parameters[['defpExportRowUp']]@defVal <- 0
      }  else prec@parameters[['defpExportRowUp']]@defVal <- 1
      # defpImportRowUp
      gg <- getParameterData(prec@parameters[['pImportRow']])
#      if (prec@parameters[['pImportRow']]@nValues != -1)
#        gg <- gg[seq(length.out = prec@parameters[['pImportRow']]@nValues),, drop = FALSE]
      gg <- gg[gg$type == 'up' & gg$value != Inf, ]
      if (nrow(gg) != 0) {
        prec@parameters[['defpImportRowUp']] <- addData(prec@parameters[['defpImportRowUp']], 
          gg[, 1:(ncol(gg) - 2), drop = FALSE])
      } else if (nrow(gg) == 0 && prec@parameters[['pImportRow']]@defVal[2] == Inf) {
        prec@parameters[['defpImportRowUp']]@defVal <- 0
      }  else prec@parameters[['defpImportRowUp']]@defVal <- 1
      # For remove emission equation
      g1 <- getParameterData(prec@parameters$pTechEmisComm)
#      if (prec@parameters[['pTechEmisComm']]@nValues != -1)
#        g1 <- g1[seq(length.out = prec@parameters[['pTechEmisComm']]@nValues),, drop = FALSE]
      g2 <- getParameterData(prec@parameters$pEmissionFactor)
#      if (prec@parameters[['pEmissionFactor']]@nValues != -1)
#        g2 <- g2[seq(length.out = prec@parameters[['pEmissionFactor']]@nValues),, drop = FALSE]
      g1 <- g1[g1$value != 0, , drop = FALSE]
      for(g in unique(g2$comm)) {
        cmd <- g2[g2$comm == g, 'commp']
        tec <- unique(g1[g1$comm %in% cmd, 'tech'])
        prec@parameters$mTechEmitedComm <- addData(prec@parameters$mTechEmitedComm,
          data.frame(tech = tec, comm = rep(g, length(tec))))
      }
      # Tech oilfe
      olf <- getParameterData(prec@parameters$pTechOlife)
      inv <- getParameterData(prec@parameters$pTechInvcost)
      olf <- olf[olf$value == Inf,, drop = FALSE]
      if (nrow(olf) > 0) {
        inv <- aggregate(inv$value, by = inv[, c('tech', 'region')], FUN = "max")
        inv <- inv[inv$tech %in% unique(olf$tech) & inv$x != 0,, drop = FALSE]
        oo <- paste(olf$tech, olf$region, sep = '#')
        ii <- paste(inv$tech, inv$region, sep = '#')
        if (any(oo %in%  ii)) {
          print('There is technology with infinite olife and non zero invcost: ')
          print(inv[ii %in% oo, -ncol(inv), drop = FALSE])
          stop('See previous errors')
        }
        prec@parameters$ndefpTechOlife <- addData(prec@parameters$ndefpTechOlife, olf[, -ncol(olf), drop = FALSE])
      }
      # Check user error
      check_parameters(prec)
########
#  Remove unused technology
########
    for(i in seq(along =obj@data)) {
        FF <- rep(TRUE, length(obj@data[[i]]@data))
        for(j in seq(along = obj@data[[i]]@data)) if (class(obj@data[[i]]@data[[j]]) == 'constrain') {
          if (any(names(obj@data[[i]]@data[[j]]@for.each) == 'tech') && 
            !is.null(obj@data[[i]]@data[[j]]@for.each$tech)) {
            obj@data[[i]]@data[[j]]@for.each$tech <- obj@data[[i]]@data[[j]]@for.each$tech[
              obj@data[[i]]@data[[j]]@for.each$tech %in% prec@parameters$tech@data$tech]
              if (length(obj@data[[i]]@data[[j]]@for.each$tech) == 0) FF[j] <- FALSE
          }
          if (any(names(obj@data[[i]]@data[[j]]@for.sum) == 'tech') && 
            !is.null(obj@data[[i]]@data[[j]]@for.sum$tech)) {
            obj@data[[i]]@data[[j]]@for.sum$tech <- obj@data[[i]]@data[[j]]@for.sum$tech[
              obj@data[[i]]@data[[j]]@for.sum$tech %in% prec@parameters$tech@data$tech]
              if (length(obj@data[[i]]@data[[j]]@for.sum$tech) == 0) FF[j] <- FALSE
          }
        }
        obj@data[[i]]@data <- obj@data[[i]]@data[FF]
    }
    # Early reteirment
    if (!obj@early.retirement) {
      prec@parameters$mTechRetirement@data <- prec@parameters$mTechRetirement@data[0,, drop = FALSE]
      if (prec@parameters$mTechRetirement@nValues != -1)
        prec@parameters$mTechRetirement@nValues <- 0
    }
#!################
### FUNC GAMS 
  #### Code load
  run_code <- energyRt::modelCode[[solver]][[model.type]]
  if (open.folder) shell.exec(tmpdir)
  if (solver == 'GAMS') {
        zz <- file(paste(tmpdir, '/mdl.gpr', sep = ''), 'w')
    cat(c('[RP:MDL]', '1=', '', '[OPENWINDOW_1]', 
      gsub('[/][/]*', '\\\\', paste('FILE0=', tmp.dir, '/mdl.gms', sep = '')),
      gsub('[/][/]*', '\\\\', paste('FILE1=', tmp.dir, '/mdl.lst', sep = '')), '', 'MAXIM=1', 
      'TOP=50', 'LEFT=50', 'HEIGHT=400', 'WIDTH=400', ''), sep = '\n', file = zz)
    close(zz)
   zz <- file(paste(tmpdir, '/mdl.gms', sep = ''), 'w')
   cat(run_code[1:(grep('e0fc7d1e-fd81-4745-a0eb-2a142f837d1c', run_code) - 1)], sep = '\n', file = zz)
   prec <<- prec 
   for(i in names(prec@parameters)) if (prec@parameters[[i]]@type == 'set') {
      cat(energyRt:::.toGams(prec@parameters[[i]]), sep = '\n', file = zz)
    }
    for(i in names(prec@parameters)) if (prec@parameters[[i]]@type == 'map') {
      cat(energyRt:::.toGams(prec@parameters[[i]]), sep = '\n', file = zz)
    }
    for(i in names(prec@parameters)) if (prec@parameters[[i]]@type == 'simple') {
      cat(energyRt:::.toGams(prec@parameters[[i]]), sep = '\n', file = zz)
    }
    for(i in names(prec@parameters)) if (prec@parameters[[i]]@type == 'multi') {
      cat(energyRt:::.toGams(prec@parameters[[i]]), sep = '\n', file = zz)
    }
    cat(run_code[(grep('e0fc7d1e-fd81-4745-a0eb-2a142f837d1c', run_code) + 1):
        (grep('c7a5e905-1d09-4a38-bf1a-b1ac1551ba4f', run_code) - 1)], sep = '\n', file = zz)
    cat(run_code[(grep('c7a5e905-1d09-4a38-bf1a-b1ac1551ba4f', run_code) + 1):
        (grep('ddd355e0-0023-45e9-b0d3-1ad83ba74b3a', run_code) - 1)], sep = '\n', file = zz)
  
    cat(run_code[(grep('ddd355e0-0023-45e9-b0d3-1ad83ba74b3a', run_code) + 1):
        (grep('f374f3df-5fd6-44f1-b08a-1a09485cbe3d', run_code) - 1)], sep = '\n', file = zz)
    if (only.listing) {
      cat('OPTION RESLIM=50000, PROFILE=1, SOLVEOPT=REPLACE;\n',
          'OPTION ITERLIM=999999, LIMROW=10000, LIMCOL=10000, SOLPRINT=ON;\n',
          'option iterlim = 0;\n', 
          'Solve st_model minimizing vObjective using LP;\n$EXIT\n', file = zz, sep = '')
    
    }
    cat(obj@misc$additionalCode, sep = '\n', file = zz)
    cat(run_code[(grep('f374f3df-5fd6-44f1-b08a-1a09485cbe3d', run_code) + 1):(
        grep('47b574db-2b0b-4556-a2e1-b323430d6ae6', run_code) - 1)], sep = '\n', file = zz)
    cat(obj@misc$additionalCodeAfter, sep = '\n', file = zz)
    cat(run_code[(min(c(grep('47b574db-2b0b-4556-a2e1-b323430d6ae6', run_code) + 1, length(run_code)))):length(run_code)], sep = '\n', file = zz)
    # Add constrain file to read list
    close(zz)
    pp2 <- proc.time()[3]
    if (echo) { 
      cat('Total preprocessing time: ', round(pp2 - pp1, 2), 's\n', sep = '')
      flush.console()
    }
    tryCatch({
      setwd(tmpdir)
      if (.Platform$OS.type == "windows") {
        rs <- system(paste('gams mdl.gms', gamsCompileParameter), invisible = arg_invisible, 
          show.output.on.console = show.output.on.console)
      } else {
        rs <- system(paste('gams mdl.gms', gamsCompileParameter))
      }
      setwd(BEGINDR)  
    }, interrupt = function(x) {
      if (tmp.del) unlink(tmpdir, recursive = TRUE)
      setwd(BEGINDR)
      stop('Solver has been interrupted')
    }, error = function(x) {
      if (tmp.del) unlink(tmpdir, recursive = TRUE)
      setwd(BEGINDR)
      stop(x)
    })    
    if (rs != 0) stop(paste('Solution error code', rs))
    if (only.listing) {
      return(readLines(paste(tmpdir, '/mdl.lst', sep = '')))
    }
    pp3 <- proc.time()[3]
    if(echo) cat('Solver work time: ', round(pp3 - pp2, 2), 's\n', sep = '')
  } else if (solver == 'GLPK' || solver == 'CBC') {   
### FUNC GLPK 
      zz <- file(paste(tmpdir, '/glpk.mod', sep = ''), 'w')
      if (length(grep('^minimize', run_code)) != 1) stop('Wrong GLPK model')
      cat(run_code[1:(grep('^minimize', run_code) - 1)], sep = '\n', file = zz)
#      for(i in seq(along = CNS)) {
#        cat(CNS[[i]]$add_code, sep = '\n', file = zz)
#      }
      cat(run_code[grep('^minimize', run_code):(grep('^end[;]', run_code) - 1)], 
          sep = '\n', file = zz)
      cat(run_code[grep('^end[;]', run_code):length(run_code)], sep = '\n', file = zz)
      close(zz)
      zz <- file(paste(tmpdir, '/glpk.dat', sep = ''), 'w') 
    for(i in names(prec@parameters)) if (prec@parameters[[i]]@type == 'set') {
      cat(energyRt:::.sm_to_glpk(prec@parameters[[i]]), sep = '\n', file = zz)
    }
    cat('set FORIF := FORIFSET;\n', sep = '\n', file = zz)
    for(i in names(prec@parameters)) if (prec@parameters[[i]]@type == 'map') {
      cat(energyRt:::.sm_to_glpk(prec@parameters[[i]]), sep = '\n', file = zz)
    }
    for(i in names(prec@parameters)) if (prec@parameters[[i]]@type == 'simple') {
      cat(energyRt:::.sm_to_glpk(prec@parameters[[i]]), sep = '\n', file = zz)
    }
    for(i in names(prec@parameters)) if (prec@parameters[[i]]@type == 'multi') {
      cat(energyRt:::.sm_to_glpk(prec@parameters[[i]]), sep = '\n', file = zz)
    }                            
#    for(i in seq(along = CNS)) {
#      cat(CNS[[i]]$add_data, sep = '\n', file = zz)
#    }
    ##!!!!!!!!!!!!!!!!!!!!!
    ## ORD function
    cat('param ORD :=', sep = '\n', file = zz)  
    cat(paste(prec@parameters$year@data$year, seq(along = prec@parameters$year@data$year)), sep = '\n', file = zz)
    cat(';', '', sep = '\n', file = zz) 
    cat('end;', '', sep = '\n', file = zz) 
    ##!!!!!!!!!!!!!!!!!!!!!  
    close(zz)
    pp2 <- proc.time()[3]
    if(echo) {
      cat('Total preprocessing time: ', round(pp2 - pp1, 2), 's\n', sep = '')
      flush.console()
    }
    tryCatch({
      setwd(tmpdir)
      if (.Platform$OS.type == "windows") {
        if (solver  == 'GLPK') {
#<<<<<<< HEAD
#          rs <- system('glpsol.exe -m glpk.mod -d glpk.dat --log log.csv --exact')      
##          rs <- system('glpsol.exe -m glpk.mod -d glpk.dat --log log.csv --xcheck')      
#        } else {
#          rs <- system("cbc glpk.mod%glpk.dat -solve")
#        }
#      } else {
#        if (solver  == 'GLPK') {
#          rs <- system('glpsol -m glpk.mod -d glpk.dat --log log.csv') #, mustWork = TRUE)
#          rs <- system('glpsol -m glpk.mod -d glpk.dat --log log.csv --xcheck') #, mustWork = TRUE)
## =======
          rs <- system(paste('glpsol.exe -m glpk.mod -d glpk.dat --log log.csv', glpkCompileParameter), 
          invisible = arg_invisible, show.output.on.console = show.output.on.console)
        } else {
          rs <- system(paste("cbc glpk.mod%glpk.dat -solve", cbcCompileParameter, 
            show.output.on.console = show.output.on.console,  invisible = arg_invisible))
        }
      } else {
        if (solver  == 'GLPK') {
          rs <- system(paste('glpsol -m glpk.mod -d glpk.dat --log log.csv', 
              glpkCompileParameter)) #, mustWork = TRUE)
#>>>>>>> 00e795fd76161408e7b5782a3aaf58177d36e20e
        } else {
          rs <- system(paste("cbc glpk.mod%glpk.dat -solve", cbcCompileParameter))
        }
      }
      setwd(BEGINDR)  
      if (rs != 0) stop(paste('Error in compilation with code', rs))
    }, interrupt = function(x) {
      if (tmp.del) unlink(tmpdir, recursive = TRUE)
      setwd(BEGINDR)
      stop('Solver have been interrupted')
    }, error = function(x) {
      if (tmp.del) unlink(tmpdir, recursive = TRUE)
      setwd(BEGINDR)
      stop(x)
    })    
      pp3 <- proc.time()[3]
      if(echo) cat('Solver work time: ', round(pp3 - pp2, 2), 's\n', sep = '')
      if (any(grep('OPTIMAL.*SOLUTION FOUND', readLines(paste(tmpdir, '/log.csv', sep = ''))))) {
        z3 <- file(paste(tmpdir, '/pStat.csv', sep = ''), 'w')
        cat('value\n1.00\n', file = z3)
        close(z3)
      } else {
        z3 <- file(paste(tmpdir, '/pStat.csv', sep = ''), 'w')
        cat('value\n2.00\n', file = z3)
        close(z3)
      }
  } else stop('Unknown solver ', solver)
    vrb_list <- read.csv(paste(tmpdir, '/variable_list.csv', sep = ''), stringsAsFactors = FALSE)$value
    if (file.exists(paste(tmpdir, '/variable_list2.csv', sep = ''))) {
      vrb_list2 <- read.csv(paste(tmpdir, '/variable_list2.csv', sep = ''), stringsAsFactors = FALSE)$value
    } else vrb_list2 <- character()
    rr <- list(variables = list(), par_arr = list(), set = read.csv(paste(tmpdir, 
      '/raw_data_set.csv', sep = ''), stringsAsFactors = FALSE))
    ss <- list()
    for(k in unique(rr$set$set)) {
      ss[[k]] <- rr$set$value[rr$set$set == k]
    }
    # add alias
    ss$src <- ss$region
    ss$dst <- ss$region
    ss$regionp <- ss$region
    ss$yearp <- ss$year
    ss$acomm <- ss$comm
    ss$commp <- ss$comm
    rr$set_vec <- ss
    for(i in vrb_list) {
      gg <- read.csv(paste(tmpdir, '/', i, '.csv', sep = ''), stringsAsFactors = FALSE)
      if (ncol(gg) == 1) {
        rr$par_arr[[i]] <- gg[1, 1]  
        rr$variables[[i]] <- data.frame(value = gg[1, 1])
      } else {
        rr$variables[[i]] <- gg
        jj <- gg[, -ncol(gg), drop = FALSE]
        for(j in seq(length.out = ncol(jj))) {
          if (all(colnames(jj)[j] != names(rr$set_vec))) colnames(jj)[j] <- gsub('[.].*', '', colnames(jj)[j])
          jj[, j] <- factor(jj[, j], levels = sort(rr$set_vec[[colnames(jj)[j]]]))
        }
        zz <- tapply(gg[,'value'], jj, sum)
        zz[is.na(zz)] <- 0
        rr$par_arr[[i]] <- zz
      }
    }
    # Read constrain data
    for(i in vrb_list2) {
      gg <- read.csv(paste(tmpdir, '/', i, '.csv', sep = ''), stringsAsFactors = FALSE)
      if (nrow(gg) == 0) {
        rr$par_arr[[i]] <- NULL
      } else if (ncol(gg) == 2) {
        rr$par_arr[[i]] <- array(c(gg[1, 3:4], recursive = TRUE), dim = 2, dimnames = list(c('value', 'rhs')))
      } else {
        l1 <- gg[, -ncol(gg)]; l1$type[seq(length.out = nrow(gg))] <- 'rhs'
        l2 <- gg[, 1 - ncol(gg)]; l2$type[seq(length.out = nrow(gg))] <- 'value'
        colnames(l1)[ncol(l1) - 1] <- 'type'
        colnames(l2)[ncol(l2) - 1] <- 'type'
        gg <- rbind(l1, l2)
        rr$par_arr[[i]] <- tapply(gg[, ncol(gg) - 1], gg[, 1 - ncol(gg)], sum)
        
      }
    }
    rr[['solution_report']] <- list(finish = read.csv(paste(tmpdir, '/pFinish.csv', sep = ''))$value, 
      status = read.csv(paste(tmpdir, '/pStat.csv', sep = ''))$value)
    pp4 <- proc.time()[3]
     if (tmp.del) {
       #cat(tmpdir, 'yyyyyyyyyyyyyy\n')
       unlink(tmpdir, recursive = TRUE)
     }
    if(echo) cat('Total time: ', round(pp4 - pp1, 2), 's\n', sep = '')
   scn <- new('scenario')
   scn@name <- name
   scn@description <- description
   scn@modInp <- prec
   scn@model <- obj
   scn@modOut <- new('modOut')
   scn@modOut@data <- rr$par_arr
   scn@modOut@sets <- rr$set_vec
   scn@modOut@variables <- rr$variables
   scn@modOut@compilationStatus <- as.character(rr$solution_report$finish)
   scn@modOut@solutionStatus <- as.character(rr$solution_report$status)
   for(i in names(scn@modInp@parameters)) {
     if (scn@modInp@parameters[[i]]@nValues != -1) {
       scn@modInp@parameters[[i]]@data <- scn@modInp@parameters[[i]]@data[
         seq(length.out = scn@modInp@parameters[[i]]@nValues),, drop = FALSE]
     }
   }
   if (rr$solution_report$finish != 2 || rr$solution_report$status != 1)
     warning('Unsuccessful finish')
   scn
}

#setMethod('solve', signature(obj = 'model'), energyRt:::.sm_compile_model)
solve.model <- function(obj, ...) {
  if (all(names(list(...)) != 'name')) {
    warning('Scenario name is not specified, using "DEFAULT" name')
    energyRt:::.sm_compile_model(obj, name = 'DEFAULT', ...)
  } else energyRt:::.sm_compile_model(obj, ...)
}


