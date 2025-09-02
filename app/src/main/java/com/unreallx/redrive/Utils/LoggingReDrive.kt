package com.unreallx.redrive.Utils

import android.content.Context
import android.content.SharedPreferences
import android.os.Environment
import java.io.File
import java.io.IOException
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

object LoggingReDrive {
    private const val TAG = "LoggingReDrive"
    private const val PREFS_NAME = "LoggingPreferences"
    private const val LAST_LOG_FILE_INDEX = "last_log_file_index"
    private lateinit var logFile: File
    private lateinit var sharedPreferences: SharedPreferences

    fun initialize(context: Context) {
        try {
            sharedPreferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

            val fileIndex = sharedPreferences.getInt(LAST_LOG_FILE_INDEX, 0) + 1

            val downloadsDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
            if (!downloadsDir.exists()) {
                downloadsDir.mkdirs()
            }

            logFile = File(downloadsDir, "obd_data_log_$fileIndex.txt")
            logFile.createNewFile()

            sharedPreferences.edit().putInt(LAST_LOG_FILE_INDEX, fileIndex).apply()


        } catch (e: Exception) {
            null
        }
    }

    fun logDataOBD2(rpm: Int, speed: Int, engineTemp: Int) {
        try {
            val timeStamp = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault()).format(Date())
            val logMessage = "$timeStamp - RPM: $rpm, Speed: $speed km/h, Engine Temp: $engineTemp°C"
            logFile.appendText("$logMessage\n")
        } catch (e: IOException) {
            null
        }
    }

    fun logMessage(message: String) {
        try {
            val timeStamp = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault()).format(Date())
            val logMessage = "$timeStamp - $message"
            logFile.appendText("$logMessage\n")
        } catch (e: IOException) {
            null
        }
    }
}
