################################################################################
# Class generating code
################################################################################
# ! User never use this class
################################################################################
setClass("modInp", # modInp
  representation(
    set = "list", # @sets List with set : tech, sup, group, comm, region, year, slice
    parameters = "list", # @parameters List with techology parameter
    customConstrains = "list", # @customConstrains
    modelVersion        = "character",
    solver              = "character",
    misc = "list"
  ),
  prototype(
    set = list(tech = c(), sup = c(), group = c(),
                comm = c(), region = c(), year = c(), slice = c()
    ),
    parameters = list(), # List with techology parameter
    customConstrains = list(), 
    modelVersion        = "",
    solver              = "",
    #! Misc
    misc = list(
      GUID = "dc8680b2-130d-4a40-86b8-3a33018e005e"
    )
  )
);



# Constructor
setMethod("initialize", "modInp",
  function(.Object) {
  # Create parameters
    # Base set
    .Object@parameters[['region']] <- createSet('region')    
    .Object@parameters[['year']]   <- createSet('year')    
    .Object@parameters[['slice']]  <- createSet('slice')    
    .Object@parameters[['comm']]   <- createSet('comm')    
    .Object@parameters[['sup']]    <- createSet('sup')    
    .Object@parameters[['dem']]    <- createSet('dem')    
    .Object@parameters[['tech']]   <- createSet('tech')    
    .Object@parameters[['group']]  <- createSet('group')    
    .Object@parameters[['stg']]    <- createSet('stg')    
    .Object@parameters[['expp']]    <- createSet('expp')    
    .Object@parameters[['imp']]    <- createSet('imp')    
    .Object@parameters[['trade']]    <- createSet('trade')    
    .Object@parameters[['cns']] <- createSet('cns')    

        .Object@parameters[['mSlicePrevious']] <- createParameter('mSlicePrevious', c('slice', 'slice'), 'map')    
    .Object@parameters[['mSlicePreviousYear']] <- createParameter('mSlicePreviousYear', 'slice', 'map')    

  # Commodity
    # Map
    #.Object@parameters[['ems_from']] <- 
    #    createParameter('ems_from', c('comm', 'commp'), 'map')    
    .Object@parameters[['mUpComm']] <- createParameter('mUpComm', 'comm', 'map')    
    .Object@parameters[['mLoComm']] <- createParameter('mLoComm', 'comm', 'map')    
    .Object@parameters[['mFxComm']] <- createParameter('mFxComm', 'comm', 'map')    
    # simple
    .Object@parameters[['pEmissionFactor']] <- 
        createParameter('pEmissionFactor', c('comm', 'commp'), 'simple',  #PPP
        defVal = 0, interpolation = 'back.inter.forth')    
    .Object@parameters[['pAggregateFactor']] <- 
        createParameter('pAggregateFactor', c('comm', 'commp'), 'simple', #PPP
        defVal = 0, interpolation = 'back.inter.forth')    
  # Other commodity attribute
    # Demand
    # Map
    .Object@parameters[['mDemComm']] <- 
        createParameter('mDemComm', c('dem', 'comm'), 'map')    
    .Object@parameters[['pDemand']] <- 
        createParameter('pDemand', c('dem', 'region', 'year', 'slice'), 'simple', 
        defVal = 0, interpolation = 'back.inter.forth', colName = 'dem')
    # Dummy import
    .Object@parameters[['pDummyImportCost']] <- 
        createParameter('pDummyImportCost', c('comm', 'region', 'year', 'slice'), 'simple', 
        defVal = Inf, interpolation = 'back.inter.forth', colName = 'dummyImport')    
    # Dummy export
    .Object@parameters[['pDummyExportCost']] <- 
        createParameter('pDummyExportCost', c('comm', 'region', 'year', 'slice'), 'simple', 
        defVal = Inf, interpolation = 'back.inter.forth', colName = 'dummyExport')    
    # Tax
    .Object@parameters[['pTaxCost']] <- 
        createParameter('pTaxCost', c('comm', 'region', 'year', 'slice'), 'simple', 
        defVal = 0, interpolation = 'inter.forth', colName = 'tax')    
    # Subs
    .Object@parameters[['pSubsCost']] <- 
        createParameter('pSubsCost', c('comm', 'region', 'year', 'slice'), 'simple', 
        defVal = 0, interpolation = 'inter.forth', colName = 'subs')    
  # Supply
    # Map
    .Object@parameters[['mSupComm']] <- 
        createParameter('mSupComm', c('sup', 'comm'), 'map')    
    .Object@parameters[['mSupSpan']] <- 
        createParameter('mSupSpan', c('sup', 'region'), 'map')    
    # simple
    .Object@parameters[['pSupCost']] <- 
        createParameter('pSupCost', c('sup', 'region', 'year', 'slice'), 'simple', 
        defVal = 0, interpolation = 'back.inter.forth', colName = 'cost')    
    .Object@parameters[['pSupReserve']] <- 
        createParameter('pSupReserve', c('sup'), 'simple', 
        defVal = Inf, interpolation = 'back.inter.forth')    
    # multi
    .Object@parameters[['pSupAva']] <- 
        createParameter('pSupAva', c('sup', 'region', 'year', 'slice'), 'multi', 
        defVal = c(0, Inf), interpolation = 'back.inter.forth', 
          colName = c('ava.lo', 'ava.up'))    
  # Technology
    # Map
    for(i in c('mTechInpComm', 'mTechOutComm', 'mTechOneComm', 
      'mTechEmitedComm', 'mTechAInp', 'mTechAOut'))
        .Object@parameters[[i]] <- createParameter(i, c('tech', 'comm'), 'map')    
#    for(i in c('mTechCinpAInp', 'mTechCoutAInp', 'mTechCinpAOut', 'mTechCoutAOut'))
#        .Object@parameters[[i]] <- createParameter(i, c('tech', 'comm', 'commp'), 'map')    
    for(i in c('mTechInpGroup', 'mTechOutGroup'))
        .Object@parameters[[i]] <- createParameter(i, c('tech', 'group'), 'map')    
    .Object@parameters[['mTechGroupComm']] <- createParameter('mTechGroupComm', 
        c('tech', 'group', 'comm'), 'map')    
#    .Object@parameters[['mTechStartYear']] <- createParameter('mTechStartYear', 
#        c('tech', 'region', 'year'), 'map')    
#    .Object@parameters[['mTechEndYear']] <- createParameter('mTechEndYear', 
#        c('tech', 'region', 'year'), 'map')    
    .Object@parameters[['mTechUpgrade']] <- createParameter('mTechUpgrade', 
        c('tech', 'techp'), 'map')    
    .Object@parameters[['mTechRetirement']] <- createParameter('mTechRetirement', c('tech'), 'map')    
    # For disable technology with unexceptable start year
    .Object@parameters[['mTechNew']] <- createParameter('mTechNew', c('tech', 'region', 'year'), 'map')    
    .Object@parameters[['mTechSpan']] <- createParameter('mTechSpan', c('tech', 'region', 'year'), 'map')    
    # simple & multi
    .Object@parameters[['pTechCap2act']] <- 
        createParameter('pTechCap2act', 'tech', 'simple', 
        defVal = 1, interpolation = 'back.inter.forth')    
    .Object@parameters[['pTechEmisComm']] <- createParameter('pTechEmisComm', c('tech', 'comm'), 'simple', defVal = 1)    
    .Object@parameters[['pTechOlife']] <- 
        createParameter('pTechOlife', c('tech', 'region'), 'simple', 
        defVal = 1, interpolation = 'back.inter.forth', colName = 'olife')          
        .Object@parameters[['pTechFixom']] <- createParameter('pTechFixom', 
              c('tech', 'region', 'year'), 'simple', 
        defVal = 0, interpolation = 'back.inter.forth', colName = 'fixom')    
        .Object@parameters[['pTechInvcost']] <- createParameter('pTechInvcost', 
              c('tech', 'region', 'year'), 'simple', 
        defVal = 0, interpolation = 'back.inter.forth', colName = 'invcost')    
        .Object@parameters[['pTechStock']] <- createParameter('pTechStock', 
              c('tech', 'region', 'year'), 'simple', 
        defVal = 0, interpolation = 'back.inter.forth', colName = 'stock')    
        .Object@parameters[['pTechVarom']] <- createParameter('pTechVarom', 
              c('tech', 'region', 'year', 'slice'), 'simple', 
                defVal = 0, interpolation = 'back.inter.forth', colName = 'varom')    
        .Object@parameters[['pTechAfa']] <- createParameter('pTechAfa', 
              c('tech', 'region', 'year', 'slice'), 'multi', 
                defVal = c(0, 1), interpolation = 'back.inter.forth', 
                colName = c('afa.lo', 'afa.up'))    
        .Object@parameters[['pTechGinp2use']] <- createParameter('pTechGinp2use', 
              c('tech', 'group', 'region', 'year', 'slice'), 'simple', 
                defVal = 1, interpolation = 'back.inter.forth', colName = 'ginp2use')    
        .Object@parameters[['pTechCinp2ginp']] <- createParameter('pTechCinp2ginp', 
              c('tech', 'comm', 'region', 'year', 'slice'), 'simple', 
                defVal = 1, interpolation = 'back.inter.forth', colName = 'cinp2ginp')    
        .Object@parameters[['pTechUse2cact']] <- createParameter('pTechUse2cact', 
              c('tech', 'comm', 'region', 'year', 'slice'), 'simple', 
                defVal = 1, interpolation = 'back.inter.forth', colName = 'use2cact')    
        # Aux
        .Object@parameters[['pTechUse2AInp']] <- createParameter('pTechUse2AInp', 
              c('tech', 'acomm', 'region', 'year', 'slice'), 'simple', 
                defVal = 0, interpolation = 'back.inter.forth', colName = 'use2ainp')    
        .Object@parameters[['pTechAct2AInp']] <- createParameter('pTechAct2AInp', 
              c('tech', 'acomm', 'region', 'year', 'slice'), 'simple', 
                defVal = 0, interpolation = 'back.inter.forth', colName = 'act2ainp')    
        .Object@parameters[['pTechCap2AInp']] <- createParameter('pTechCap2AInp', 
              c('tech', 'acomm', 'region', 'year', 'slice'), 'simple', 
                defVal = 0, interpolation = 'back.inter.forth', colName = 'cap2ainp')    
        .Object@parameters[['pTechUse2AOut']] <- createParameter('pTechUse2AOut', 
              c('tech', 'acomm', 'region', 'year', 'slice'), 'simple', 
                defVal = 0, interpolation = 'back.inter.forth', colName = 'use2aout')    
        .Object@parameters[['pTechAct2AOut']] <- createParameter('pTechAct2AOut', 
              c('tech', 'acomm', 'region', 'year', 'slice'), 'simple', 
                defVal = 0, interpolation = 'back.inter.forth', colName = 'act2aout')    
        .Object@parameters[['pTechCap2AOut']] <- createParameter('pTechCap2AOut', 
              c('tech', 'acomm', 'region', 'year', 'slice'), 'simple', 
                defVal = 0, interpolation = 'back.inter.forth', colName = 'cap2aout')    

        .Object@parameters[['pTechNCap2AInp']] <- createParameter('pTechNCap2AInp', 
              c('tech', 'acomm', 'region', 'year', 'slice'), 'simple', 
                defVal = 0, interpolation = 'back.inter.forth', colName = 'cap2aout')    
        .Object@parameters[['pTechNCap2AOut']] <- createParameter('pTechNCap2AOut', 
              c('tech', 'acomm', 'region', 'year', 'slice'), 'simple', 
                defVal = 0, interpolation = 'back.inter.forth', colName = 'cap2aout')    

        .Object@parameters[['pTechCinp2AInp']] <- createParameter('pTechCinp2AInp', 
              c('tech', 'acomm', 'comm', 'region', 'year', 'slice'), 'simple', 
                defVal = 0, interpolation = 'back.inter.forth', colName = 'cinp2ainp')    
        .Object@parameters[['pTechCout2AInp']] <- createParameter('pTechCout2AInp', 
              c('tech', 'acomm', 'comm', 'region', 'year', 'slice'), 'simple', 
                defVal = 0, interpolation = 'back.inter.forth', colName = 'cout2ainp')    
        .Object@parameters[['pTechCinp2AOut']] <- createParameter('pTechCinp2AOut', 
              c('tech', 'acomm', 'comm', 'region', 'year', 'slice'), 'simple', 
                defVal = 0, interpolation = 'back.inter.forth', colName = 'cinp2aout')    
        .Object@parameters[['pTechCout2AOut']] <- createParameter('pTechCout2AOut', 
              c('tech', 'acomm', 'comm', 'region', 'year', 'slice'), 'simple', 
                defVal = 0, interpolation = 'back.inter.forth', colName = 'cout2aout')    

        # Aux stop
        .Object@parameters[['pTechCact2cout']] <- createParameter('pTechCact2cout', 
              c('tech', 'comm', 'region', 'year', 'slice'), 'simple', 
                defVal = 1, interpolation = 'back.inter.forth', colName = 'cact2cout')    
        .Object@parameters[['pTechCinp2use']] <- createParameter('pTechCinp2use', 
              c('tech', 'comm', 'region', 'year', 'slice'), 'simple', 
                defVal = 1, interpolation = 'back.inter.forth', colName = 'cinp2use')  
        .Object@parameters[['pTechCvarom']] <- createParameter('pTechCvarom', 
              c('tech', 'comm', 'region', 'year', 'slice'), 'simple', 
                defVal = 0, interpolation = 'back.inter.forth', colName = 'cvarom')    
        .Object@parameters[['pTechAvarom']] <- createParameter('pTechAvarom', 
              c('tech', 'acomm', 'region', 'year', 'slice'), 'simple', 
                defVal = 0, interpolation = 'back.inter.forth', colName = 'avarom')    
        .Object@parameters[['pTechShare']] <- createParameter('pTechShare', 
              c('tech', 'comm', 'region', 'year', 'slice'), 'multi', 
                defVal = c(0, 1), interpolation = 'back.inter.forth', 
                colName = c('share.lo', 'share.up'))    
        .Object@parameters[['pTechAfac']] <- createParameter('pTechAfac', 
              c('tech', 'comm', 'region', 'year', 'slice'), 'multi', 
                defVal = c(0, Inf), interpolation = 'back.inter.forth', 
                colName = c('afac.lo', 'afac.up'))
                
  ## NEED SET ALIAS FOR SYS INFO
  # Reserve
    .Object@parameters[['mStorageComm']] <- createParameter('mStorageComm', c('stg', 'comm'), 'map')    
    # simple & multi
        .Object@parameters[['pStorageOlife']] <- createParameter('pStorageOlife', 
              c('stg', 'region'), 'simple', 
                defVal = 1, interpolation = 'back.inter.forth')    
    for(i in c('pStorageStock', 'pStorageFixom', 'pStorageInvcost'))
        .Object@parameters[[i]] <- createParameter(i, 
              c('stg', 'region', 'year'), 'simple', 
                defVal = 0, interpolation = 'back.inter.forth')    
    for(i in c('pStorageInpLoss', 'pStorageOutLoss', 'pStorageStoreStock',
               'pStorageCostStore', 'pStorageCostInp', 'pStorageCostOut'))
        .Object@parameters[[i]] <- createParameter(i, 
              c('stg', 'region', 'year', 'slice'), 'simple', 
                defVal = 0, interpolation = 'back.inter.forth')    
    .Object@parameters[['pStorageStoreLoss']] <- createParameter('pStorageStoreLoss', 
          c('stg', 'region', 'year', 'slice'), 'simple', 
            defVal = 0, interpolation = 'back.inter.forth')    
    .Object@parameters[['pStorageCap']] <- createParameter('pStorageCap', 
          c('stg', 'region', 'year'), 'multi', 
            defVal = c(0, Inf), interpolation = 'back.inter.forth')
    .Object@parameters[['mStorageNew']] <- createParameter('mStorageNew', c('stg', 'region', 'year'), 'map')    
    .Object@parameters[['mStorageSpan']] <- createParameter('mStorageSpan', c('stg', 'region', 'year'), 'map')    
  # Trade
    # Map
    .Object@parameters[['mExpComm']] <- 
        createParameter('mExpComm', c('expp', 'comm'), 'map')    
    .Object@parameters[['mImpComm']] <- 
        createParameter('mImpComm', c('imp', 'comm'), 'map')    
    .Object@parameters[['mTradeComm']] <- 
        createParameter('mTradeComm', c('trade', 'comm'), 'map')    
    .Object@parameters[['mTradeSrc']] <- 
        createParameter('mTradeSrc', c('trade', 'region'), 'map')    
    .Object@parameters[['mTradeDst']] <- 
        createParameter('mTradeDst', c('trade', 'region'), 'map')    
    .Object@parameters[['mSlicePrevious']] <- createParameter('mSlicePrevious', c('slice', 'slice'), 'map')    
    .Object@parameters[['pTradeIrCost']] <- createParameter('pTradeIrCost', 
          c('trade', 'src', 'dst', 'year', 'slice'), 'simple', 
            defVal = 0, interpolation = 'back.inter.forth')    
    .Object@parameters[['pTradeIrMarkup']] <- createParameter('pTradeIrMarkup', 
          c('trade', 'src', 'dst', 'year', 'slice'), 'simple', 
            defVal = 0, interpolation = 'back.inter.forth')    
    .Object@parameters[['pExportRowPrice']] <- createParameter('pExportRowPrice', 
          c('expp', 'region', 'year', 'slice'), 'simple', 
            defVal = 0, interpolation = 'back.inter.forth')    
    .Object@parameters[['pImportRowPrice']] <- createParameter('pImportRowPrice', 
          c('imp', 'region', 'year', 'slice'), 'simple', 
            defVal = 0, interpolation = 'back.inter.forth')    
    .Object@parameters[['pTradeIr']] <- createParameter('pTradeIr', 
          c('trade', 'src', 'dst', 'year', 'slice'), 'multi', 
            defVal = c(0, Inf), interpolation = 'back.inter.forth')
    .Object@parameters[['pExportRow']] <- createParameter('pExportRow', 
          c('expp', 'region', 'year', 'slice'), 'multi', 
            defVal = c(0, Inf), interpolation = 'back.inter.forth')
    .Object@parameters[['pImportRow']] <- createParameter('pImportRow', 
          c('imp', 'region', 'year', 'slice'), 'multi', 
            defVal = c(0, Inf), interpolation = 'back.inter.forth')
    .Object@parameters[['pExportRowRes']] <- createParameter('pExportRowRes', 
          'expp', 'simple',  defVal = 0, interpolation = 'back.inter.forth')
    .Object@parameters[['pImportRowRes']] <- createParameter('pImportRowRes', 
          'imp', 'simple',  defVal = 0, interpolation = 'back.inter.forth')
  # For LEC
  .Object@parameters[['mLECRegion']] <- createParameter('mLECRegion', 'region', 'map')    
  .Object@parameters[['pLECLoACT']] <- 
        createParameter('pLECLoACT', 'region', 'simple', 
                defVal = 0, interpolation = 'back.inter.forth')    

  # Standard constraint
    # Map
    for(i in c("mCnsLType", "mCnsLhsComm", "mCnsLhsRegion", "mCnsLhsYear", "mCnsLhsSlice", 
      "mCnsLe", "mCnsGe", "mCnsRhsTypeShareIn", "mCnsRhsTypeShareOut", "mCnsRhsTypeConst", "mCnsInpTech", 
      "mCnsOutTech", "mCnsCapTech", "mCnsNewCapTech", "mCnsOutSup", "mCnsInp", "mCnsOut", "mCnsInvTech",
      "mCnsEacTech", "mCnsTechCInp", "mCnsTechCOut", "mCnsTechAInp", "mCnsTechAOut", "mCnsTechEmis",
      "mCnsActTech", "mCnsRhsTypeGrowth", "mCnsFixomTech", 
      "mCnsVaromTech", "mCnsActVaromTech", "mCnsCVaromTech", "mCnsAVaromTech", "mCnsBalance"))
        .Object@parameters[[i]] <- createParameter(i, 'cns', 'map')    
    for(i in c('tech', 'sup', 'comm', 'region', 'year', 'slice')) {
        nn <- paste('mCns', toupper(substr(i, 1, 1)), substr(i, 2, nchar(i)), sep = '')
        .Object@parameters[[nn]] <- createParameter(nn, c('cns', i), 'map')    
    }
    .Object@parameters[['mCnsTech']] <- createParameter('mCnsTech', c('cns', 'tech'), 'map') 
    .Object@parameters[['mCnsSup']] <- createParameter('mCnsSup', c('cns', 'sup'), 'map') 
    for(i in c("pRhs(cns)", "pRhsS(cns, slice)", "pRhsY(cns, year)", "pRhsYS(cns, year, slice)", 
      "pRhsR(cns, region)", "pRhsRS(cns, region, slice)", "pRhsRY(cns, region, year)", 
      "pRhsRYS(cns, region, year, slice)", "pRhsC(cns, comm)", "pRhsCS(cns, comm, slice)", 
      "pRhsCY(cns, comm, year)", "pRhsCYS(cns, comm, year, slice)", "pRhsCR(cns, comm, region)", 
      "pRhsCRS(cns, comm, region, slice)", "pRhsCRY(cns, comm, region, year)", 
      "pRhsCRYS(cns, comm, region, year, slice)", "pRhsTech(cns, tech)", 
      "pRhsTechS(cns, tech, slice)", "pRhsTechY(cns, tech, year)", "pRhsTechYS(cns, tech, year, slice)", 
      "pRhsTechR(cns, tech, region)", "pRhsTechRS(cns, tech, region, slice)", 
      "pRhsTechRY(cns, tech, region, year)", "pRhsTechRYS(cns, tech, region, year, slice)", 
      "pRhsTechC(cns, tech, comm)", "pRhsTechCS(cns, tech, comm, slice)", "pRhsTechCY(cns, tech, comm, year)",
      "pRhsTechCYS(cns, tech, comm, year, slice)", "pRhsTechCR(cns, tech, comm, region)", 
      "pRhsTechCRS(cns, tech, comm, region, slice)", "pRhsTechCRY(cns, tech, comm, region, year)", 
      "pRhsTechCRYS(cns, tech, comm, region, year, slice)", "pRhsSup(cns, sup)", 
      "pRhsSupS(cns, sup, slice)", "pRhsSupY(cns, sup, year)", "pRhsSupYS(cns, sup, year, slice)", 
      "pRhsSupR(cns, sup, region)", "pRhsSupRS(cns, sup, region, slice)", "pRhsSupRY(cns, sup, region, year)",
      "pRhsSupRYS(cns, sup, region, year, slice)", "pRhsSupC(cns, sup, comm)", "pRhsSupCS(cns, sup, comm, slice)",
      "pRhsSupCY(cns, sup, comm, year)", "pRhsSupCYS(cns, sup, comm, year, slice)", 
      "pRhsSupCR(cns, sup, comm, region)", "pRhsSupCRS(cns, sup, comm, region, slice)", 
      "pRhsSupCRY(cns, sup, comm, region, year)", "pRhsSupCRYS(cns, sup, comm, region, year, slice)")) {
      .Object@parameters[[gsub('[(].*', '', i)]] <- createParameter(gsub('[(].*', '', i), 
            strsplit(gsub('[)]', '', gsub('.*[(]', '', i)), ', ')[[1]], 'simple', 
              defVal = 0, interpolation = 'back.inter.forth')      
    }

  # Other
    # Discount
    .Object@parameters[['pDiscount']] <- 
        createParameter('pDiscount', c('region', 'year'), 'simple', 
                defVal = .1, interpolation = 'back.inter.forth', colName = 'discount')    
  # Additional for compatibility with GLPK
  .Object@parameters[['ndefpTechOlife']] <- createParameter('ndefpTechOlife', c('tech', 'region'), 'map')   
  .Object@parameters[['defpTechAfaUp']] <- createParameter('defpTechAfaUp', c('tech', 'region', 'year', 'slice'), 'map')   
  .Object@parameters[['defpTechAfacUp']] <- 
      createParameter('defpTechAfacUp', c('tech', 'comm', 'region', 'year', 'slice'), 'map')    
  .Object@parameters[['defpSupAvaUp']] <- 
      createParameter('defpSupAvaUp', c('sup', 'region', 'year', 'slice'), 'map')    
  .Object@parameters[['defpSupReserve']] <- createParameter('defpSupReserve', c('sup'), 'map')    
  .Object@parameters[['defpStorageCapUp']] <- createParameter('defpStorageCapUp', c('stg', 'region', 'year'), 'map')    
  .Object@parameters[['defpTradeIrUp']] <- createParameter('defpTradeIrUp', 
                                        c('trade', 'src', 'dst', 'year', 'slice'), 'map')    
    .Object@parameters[['defpExportRowRes']] <- createParameter('defpExportRowRes', 'expp', 'map')    
    .Object@parameters[['defpImportRowRes']] <- createParameter('defpImportRowRes', 'imp', 'map')    
    .Object@parameters[['defpExportRowUp']] <- createParameter('defpExportRowUp', 
        c('expp', 'region', 'year', 'slice'), 'map')    
    .Object@parameters[['defpImportRowUp']] <- createParameter('defpImportRowUp', 
        c('imp', 'region', 'year', 'slice'), 'map')    
  .Object@parameters[['defpDummyImportCost']] <- createParameter('defpDummyImportCost', 
      c('comm', 'region', 'year', 'slice'), 'map')    
  .Object@parameters[['defpDummyExportCost']] <- createParameter('defpDummyExportCost', 
      c('comm', 'region', 'year', 'slice'), 'map')    
  .Object@parameters[['pDiscountFactor']] <- createParameter('pDiscountFactor', c('region', 'year'), 'simple')    
  .Object@parameters[['mDiscountZero']] <- createParameter('mDiscountZero', 'region', 'map', defVal = 1) 
  ## Milestone set
  .Object@parameters[['mMidMilestone']] <- createParameter('mMidMilestone', 'year', 'map', defVal = 1) 
  .Object@parameters[['mMilestoneHasNext']] <- createParameter('mMilestoneHasNext', 'year', 'map', defVal = 1) 
  .Object@parameters[['mMilestoneLast']] <- createParameter('mMilestoneLast', 'year', 'map', defVal = 1) 
  .Object@parameters[['mStartMilestone']] <- createParameter('mStartMilestone', c('year', 'yearp'), 'map', defVal = 1) 
  .Object@parameters[['mEndMilestone']] <- createParameter('mEndMilestone', c('year', 'yearp'), 'map', defVal = 1) 
  .Object@parameters[['mMilestoneNext']] <- createParameter('mMilestoneNext', c('year', 'yearp'), 'map', defVal = 1) 
  .Object
})

# Print
setMethod('print', 'modInp', function(x, ...) {
  if (length(x@parameters) == 0) {
    cat('There is no data\n')
  } else {
    for(i in 1:length(x@parameters)) {
      print(x@parameters[[i]])
    }
  }
})
