//package com.unreallx.redrive.map
//
//import android.content.Context
//import android.util.AttributeSet
//import org.mapsforge.core.graphics.GraphicFactory
//import org.mapsforge.core.model.LatLong
//import org.mapsforge.map.android.graphics.AndroidGraphicFactory
//import org.mapsforge.map.android.util.AndroidUtil
//import org.mapsforge.map.android.view.MapView
//import org.mapsforge.map.layer.cache.TileCache
//import org.mapsforge.map.layer.renderer.TileRendererLayer
//import org.mapsforge.map.reader.MapFile
//import org.mapsforge.map.rendertheme.ExternalRenderTheme
//import org.mapsforge.map.rendertheme.XmlRenderTheme
//import java.io.File
//
//class MapsforgeMapView @JvmOverloads constructor(
//    context: Context,
//    attrs: AttributeSet? = null
//) : MapView(context, attrs) {
//
//    init {
//        AndroidGraphicFactory.createInstance(context.applicationContext)
//
//        val mapFile = ensureMapFile(context)
//        val renderThemeFile = ensureRenderThemeFile(context)
//
//        val tileCache: TileCache = AndroidUtil.createTileCache(
//            context,
//            "mapcache",
//            model.displayModel.tileSize,
//            1f,
//            model.frameBufferModel.overdrawFactor,
//            true
//        )
//
//        val tileRendererLayer = TileRendererLayer(
//            tileCache,
//            MapFile(mapFile),
//            model.mapViewPosition,
//            AndroidGraphicFactory.INSTANCE as GraphicFactory
//        ).apply {
//            setXmlRenderTheme(ExternalRenderTheme(renderThemeFile))
//        }
//
//        layerManager.layers.add(tileRendererLayer)
//
//        setCenter(LatLong(42.0565, -87.6753))
//        setZoomLevel(12.toByte())
//    }
//
//    private fun ensureMapFile(context: Context): File {
//        val mapFileName = "m.map"
//        val outFile = File(context.filesDir, mapFileName)
//
//        if (!outFile.exists()) {
//            context.assets.open(mapFileName).use { input ->
//                outFile.outputStream().use { output ->
//                    input.copyTo(output)
//                }
//            }
//        }
//
//        return outFile
//    }
//
//    private fun ensureRenderThemeFile(context: Context): File {
//        val renderThemeFileName = "osmarender.xml"
//        val outFile = File(context.filesDir, renderThemeFileName)
//
//        if (!outFile.exists()) {
//            context.assets.open(renderThemeFileName).use { input ->
//                outFile.outputStream().use { output ->
//                    input.copyTo(output)
//                }
//            }
//        }
//
//        return outFile
//    }
//}