setClassUnion("characterOrNULL",members=c("character", "NULL"))
setGeneric("isCommodity", function(obj, name) standardGeneric("isCommodity"))
setGeneric("removePreviousCommodity", function(obj, name) standardGeneric("removePreviousCommodity"))
setGeneric("removePreviousDemand", function(obj, name) standardGeneric("removePreviousDemand"))
setGeneric("isDemand", function(obj, name) standardGeneric("isDemand"))
setGeneric("removePreviousSupply", function(obj, name) standardGeneric("removePreviousSupply"))
setGeneric("isSupply", function(obj, name) standardGeneric("isSupply"))
setGeneric("removePreviousExport", function(obj, name) standardGeneric("removePreviousExport"))
setGeneric("isExport", function(obj, name) standardGeneric("isExport"))
setGeneric("removePreviousImport", function(obj, name) standardGeneric("removePreviousImport"))
setGeneric("isImport", function(obj, name) standardGeneric("isImport"))
setGeneric("removePreviousTechnology", function(obj, name) standardGeneric("removePreviousTechnology"))
setGeneric("isTechnology", function(obj, name) standardGeneric("isTechnology"))
setGeneric("isConstrain", function(obj, name) standardGeneric("isConstrain"))
setGeneric("removePreviousSysInfo", function(obj) standardGeneric("removePreviousSysInfo"))
setGeneric("removePreviousTrade", function(obj, name) standardGeneric("removePreviousTrade"))
setGeneric("isTrade", function(obj, name) standardGeneric("isTrade"))
setGeneric('addData', function(obj, data) standardGeneric("addData"))
setGeneric('clear', function(obj) standardGeneric("clear"))
setGeneric('getSet', function(obj, set) standardGeneric("getSet"))
setGeneric('removeBySet', function(obj, set, value) standardGeneric("removeBySet"))
setGeneric('toGams', function(obj) standardGeneric("toGams"))
setGeneric('checkDuplicatedRow', function(obj) standardGeneric("checkDuplicatedRow"))
setGeneric('addSet', function(obj, set) standardGeneric("addSet"))
setGeneric('addMultipleSet', function(obj, set) standardGeneric("addMultipleSet"))
#setGeneric('solve', function(obj, ...) standardGeneric("solve"))
setGeneric('levcost', function(obj, ...) standardGeneric("levcost"))
setGeneric('interpolation', function(obj, parameter, default, ...) standardGeneric("interpolation"))
setGeneric("add0", function(obj, app, approxim) standardGeneric("add0"))
setGeneric("add_name", function(obj, app, approxim) standardGeneric("add_name"))
#setGeneric("add", function(obj, app, ...) standardGeneric("add"))
#setGeneric("add", function(obj, app) standardGeneric("add"))
#setGeneric("add", function(obj, app, ...) standardGeneric("add"))
setGeneric('interpolation_bound', function(obj, parameter, default, rule, ...)
  standardGeneric("interpolation_bound"))
setGeneric('comb_interpolation', function(obj, parameter, ...)
  standardGeneric("comb_interpolation"))
setGeneric("addLEC", function(obj, app, price, discount,
    region, start_year, slice, use_comm, use_out_price)
        standardGeneric("addLEC"))
#setGeneric("glpkCompile", function(obj) standardGeneric("glpkCompile"))
setGeneric("toGlpk", function(obj) standardGeneric("toGlpk"))
add <- function (...) UseMethod("add")
report <- function (...) UseMethod("report")
getData <- function (...) UseMethod("getData")

setGeneric("mileStoneYears", function(obj) standardGeneric("mileStoneYears"))
setGeneric("setMileStoneYears", function(obj, start, ...) standardGeneric("setMileStoneYears"))


