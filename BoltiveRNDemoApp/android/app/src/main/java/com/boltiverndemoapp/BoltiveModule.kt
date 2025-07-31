package com.boltiverndemoapp

import com.facebook.react.bridge.*
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.UIManagerHelper
import com.facebook.react.uimanager.UIManagerModule
import com.boltive.api.BoltiveMonitor
import com.boltive.api.BoltiveConfiguration
import com.boltive.api.BoltiveListener
import com.boltive.api.AdViewConfiguration
import com.google.android.gms.ads.BaseAdView
import com.google.android.gms.ads.admanager.AdManagerAdView
import android.view.ViewGroup
import android.util.Log

@ReactModule(name = BoltiveModule.NAME)
class BoltiveModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

    companion object {
        const val NAME = "BoltiveModule"
    }
    
    private var boltiveMonitor: BoltiveMonitor? = null

    override fun getName(): String {
        return NAME
    }

    @ReactMethod
    fun initialize(clientId: String, adNetwork: String, promise: Promise) {
        try {
            boltiveMonitor = BoltiveMonitor(BoltiveConfiguration(clientId))
            promise.resolve("Initialized")
        } catch (e: Exception) {
            promise.reject("BOLTIVE_INIT_ERROR", "Failed to initialize Boltive SDK: ${e.message}", e)
        }
    }

    @ReactMethod
    fun captureBanner(reactTag: Int, tagDetails: ReadableMap, promise: Promise) {
        if (boltiveMonitor == null) {
            promise.reject("BOLTIVE_NOT_INITIALIZED", "Boltive SDK not initialized. Call initialize() first.", null)
            return
        }
        
        Log.d("BoltiveModule", "captureBanner called for reactTag: $reactTag")
        
        // Run on UI thread to access views
        android.os.Handler(android.os.Looper.getMainLooper()).post {
            try {
                // Get the ReactNativeAdView using UIManagerHelper (Fabric compatible)
                val reactContext = reactApplicationContext as ReactContext
                val uiManager = UIManagerHelper.getUIManager(reactContext, 2) // Type: Fabric
                    ?: UIManagerHelper.getUIManager(reactContext, 1) // Type: Paper (legacy)
                
                if (uiManager == null) {
                    promise.reject("UI_MANAGER_NOT_FOUND", "UIManager not found", null)
                    return@post
                }
                
                val reactAdView = uiManager.resolveView(reactTag)
                if (reactAdView == null) {
                    promise.reject("VIEW_NOT_FOUND", "ReactNativeAdView not found for reactTag: $reactTag", null)
                    return@post
                }
                
                // Get the actual AdManagerAdView from the ReactNativeAdView (first child)
                val adView = if (reactAdView is ViewGroup && reactAdView.childCount > 0) {
                    val childView = reactAdView.getChildAt(0)
                    if (childView is BaseAdView) {
                        childView
                    } else {
                        Log.w("BoltiveModule", "First child is not a BaseAdView, got: ${childView.javaClass.simpleName}")
                        null
                    }
                } else {
                    Log.w("BoltiveModule", "ReactNativeAdView has no children or is not a ViewGroup")
                    null
                }
                
                if (adView == null) {
                    promise.reject("AD_VIEW_NOT_FOUND", "AdManagerAdView not found in ReactNativeAdView", null)
                    return@post
                }
                
                Log.d("BoltiveModule", "Found AdView: ${adView.javaClass.simpleName}")
                
                val adUnitId = tagDetails.getString("adUnitId") ?: ""
                val adViewConfiguration = AdViewConfiguration(320, 50, adUnitId)
                var promiseResolved = false
                
                val boltiveListener = BoltiveListener {
                    Log.d("BoltiveModule", "Boltive detected malicious content")
                    
                    if (!promiseResolved) {
                        promiseResolved = true
                        val result = Arguments.createMap()
                        result.putString("status", "analyzed")
                        result.putBoolean("shouldBlock", true)
                        result.putString("reason", "Malicious content detected by Boltive Android SDK")
                        result.putInt("reactTag", reactTag)
                        result.putString("adUnitId", adUnitId)
                        
                        promise.resolve(result)
                    }
                }
                
                // Capture the actual AdManagerAdView for analysis
                boltiveMonitor!!.capture(adView, adViewConfiguration, boltiveListener)
                
                android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                    if (!promiseResolved) {
                        promiseResolved = true
                        val result = Arguments.createMap()
                        result.putString("status", "analyzed")
                        result.putBoolean("shouldBlock", false)
                        result.putString("reason", "Clean ad")
                        result.putInt("reactTag", reactTag)
                        result.putString("adUnitId", adUnitId)
                        
                        Log.d("BoltiveModule", "No malicious content detected - ad is clean")
                        promise.resolve(result)
                    }
                }, 3000)
                
            } catch (e: Exception) {
                Log.e("BoltiveModule", "Error in captureBanner: ${e.message}", e)
                promise.reject("BOLTIVE_CAPTURE_ERROR", "Failed to analyze banner: ${e.message}", e)
            }
        }
    }
}