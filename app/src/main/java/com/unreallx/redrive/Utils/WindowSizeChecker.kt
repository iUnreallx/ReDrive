package com.unreallx.redrive.Utils

import android.content.Context
import android.content.res.Configuration

object DeviceUtils {
    fun isTablet(context: Context): Boolean {
        val screenLayout = context.resources.configuration.screenLayout and Configuration.SCREENLAYOUT_SIZE_MASK
        return screenLayout >= Configuration.SCREENLAYOUT_SIZE_LARGE
    }
}
