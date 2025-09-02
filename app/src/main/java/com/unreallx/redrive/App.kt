package com.unreallx.redrive

import android.app.Application
import com.unreallx.redrive.di.dataModule
import com.unreallx.redrive.di.interactorModule
import com.unreallx.redrive.di.useCaseModule
import com.unreallx.redrive.di.utilModule
import com.unreallx.redrive.di.viewModelModule
import org.koin.android.ext.koin.androidContext
import org.koin.core.context.startKoin

class App : Application() {

    override fun onCreate() {
        super.onCreate()

        startKoin {
            androidContext(this@App)
            modules(dataModule, interactorModule, useCaseModule, utilModule, viewModelModule)
        }
    }
}