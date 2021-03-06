if ( !isGeneric('+') ) {
  setGeneric('+', function(x, y, ...)
    standardGeneric('+'))
}

#' mapview + mapview adds data from the second map to the first
#'
#' @param e1 a leaflet or mapview map to which e2 should be added.
#' @param e2 a (spatial) object to be added or a mapview object from which
#' the objects should be added to e1.
#'
#' @examples
#' m1 <- mapView(franconia, col.regions = "red")
#' m2 <- mapView(breweries)
#'
#' ### add two mapview objects
#' m1 + m2
#' '+'(m2, m1)
#'
#' ### add layers to a mapview object
#' if (interactive()) {
#'   library(plainview)
#'   m1 + breweries + plainview::poppendorf[[4]]
#' }
#'
#' @name +
#' @docType methods
#' @rdname plus
#' @aliases +,mapview,mapview-method

setMethod("+",
          signature(e1 = "mapview",
                    e2 = "mapview"),
          function (e1, e2) {

            if (mapviewGetOption("platform") %in% c("leaflet", "leafgl")) {

              # if (length(
              #   mapview:::getCallEntryFromMap(e1@map, "addProviderTiles")
              # ) == 0) {
                idx = getCallEntryFromMap(e2@map, "addProviderTiles")
                if (length(idx) > 0) {
                  e2@map$x$calls[idx] = NULL
                }
                idx = getCallEntryFromMap(e2@map, "addLayersControl")
                if (length(idx) > 0) {
                  e2@map$x$calls[idx][[1]]$args[[1]] = character(0)
                }
              # }



              m <- appendMapCallEntries_lf(e1@map, e2@map)
              # m = removeDuplicatedMapCalls(m)
              out_obj <- append(e1@object, e2@object)
              # avoids error if calling, for example, mapview() + viewExtent(in)
              out_obj <- out_obj[lengths(out_obj) != 0]
              bb = combineExtent(out_obj, sf = FALSE, getProjection(e1@object[[1]]))
              names(bb) = NULL
              m <- leaflet::fitBounds(map = m,
                                      lng1 = bb[1],
                                      lat1 = bb[2],
                                      lng2 = bb[3],
                                      lat2 = bb[4])

              hbcalls = getCallEntryFromMap(m, "addHomeButton")
              zf = grep("Zoom full", m$x$calls[hbcalls])
              ind = hbcalls[zf]
              if (length(zf) > 0) m$x$calls[ind] = NULL
              m = leafem:::addZoomFullButton(m, out_obj)
            }

            if (mapviewGetOption("platform") == "mapdeck") {
              m = appendMapCallEntries_md(e1@map, e2@map)
              out_obj <- append(e1@object, e2@object)
            }

            out <- methods::new('mapview', object = out_obj, map = m)
            return(out)
          }
)

#' mapview + data adds spatial data (raster*, sf*, sp*) to a mapview map
#' @name +
#' @docType methods
#' @rdname plus
#' @aliases +,mapview,ANY-method
#'
setMethod("+",
          signature(e1 = "mapview",
                    e2 = "ANY"),
          function (e1, e2) {

            nm <- deparse(substitute(e2))
            e1 + mapview(e2, layer.name = nm, update_view = TRUE)

            # nm <- deparse(substitute(e2))
            # e1@map = removeMouseCoordinates(e1@map)
            # # e1 + mapview(e2, layer.name = nm)
            # m = mapview(e2, map = e1, layer.name = nm)
            # print(str(m, 5))
            # out_obj = append(e1@object, m@object)
            #
            # hbcalls = getCallEntryFromMap(m@map, "addHomeButton")
            # zf = grep("Zoom full", m@map$x$calls[hbcalls])
            # ind = hbcalls[zf]
            # if (length(zf) > 0) m@map$x$calls[ind] = NULL
            #
            # m = addZoomFullButton(m@map, out_obj)
            # out = methods::new('mapview', object = out_obj, map = m)
            # return(out)
          }
)


#' mapview + NULL returns the LHS map
#' @name +
#' @docType methods
#' @rdname plus
#' @aliases +,mapview,NULL-method
#'
setMethod("+",
          signature(e1 = "mapview",
                    e2 = "NULL"),
          function (e1, e2) {
            return(e1)
          }
)


# #' @name +
# #' @docType methods
# #' @rdname plus
# #' @aliases +,leaflet,ANY-method
#'
# setMethod("+",
#           signature(e1 = "leaflet",
#                     e2 = "ANY"),
#           function (e1, e2)
#           {
#
#             nm <- deparse(substitute(e2))
#             m <- mapView(e2, map = e1, layer.name = nm,
#                          map.types = getProviderTileNamesFromMap(e1))
#             out_obj <- list(e2)
#             ext <- createExtent(e2)
#             m <- leaflet::fitBounds(map = m@map,
#                                     lng1 = ext@xmin,
#                                     lat1 = ext@ymin,
#                                     lng2 = ext@xmax,
#                                     lat2 = ext@ymax)
#             out <- methods::new('mapview', object = out_obj, map = m)
#             return(out)
#           }
# )

#' [...]
#' @name +
#' @docType methods
#' @rdname plus
#' @aliases +,mapview,character-method
#'
setMethod("+",
          signature(e1 = "mapview",
                    e2 = "character"),
          function (e1, e2) {

            if (e2 %in% c("easteregg", "easter.egg", "easter_egg",
                          "easter", "easterEgg", "EasterEgg", "eegg",
                          "easter", "egg", "Easter", "Egg", "Nobody",
                          "Terence Hill", "trinity", "Trinity",
                          "easter egg", "Easter Egg", "Easter egg")) {
              cat("\nBehold! Someone's drawing quicker than the rest...\n\n")
              mapView(easter.egg = TRUE)
            } else {
              stop("\n\nSorry, but there seems to be someone who draws quicker than you...\n\n
                   Try again!")
            }

          }
)

