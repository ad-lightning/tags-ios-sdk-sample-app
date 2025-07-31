import React, { useEffect, useRef, useState } from 'react';
import {
    SafeAreaView,
    StyleSheet,
    Text,
    View,
    TouchableOpacity,
    Alert,
    Platform,
    findNodeHandle,
} from 'react-native';

import {
    BannerAd,
    BannerAdSize,
    MobileAds,
} from 'react-native-google-mobile-ads';

import BoltiveSDK, { BoltiveAdNetwork } from './src/BoltiveModule';

const bannerAdUnitId = Platform.select({
    ios: '/21808260008/btest-banner-bad-test-com',
    android: '/21808260008/btest-banner-bad-test-com',
});

const App = () => {
    const [isAdLoaded, setIsAdLoaded] = useState(false);
    const [adKey, setAdKey] = useState(0);
    const [monitorStatus, setMonitorStatus] = useState('Not initialized');
    const [boltiveStatus, setBoltiveStatus] = useState('Not initialized');
    const [blockCount, setBlockCount] = useState(0);
    const [isAdBlocked, setIsAdBlocked] = useState(false);

    const bannerRef = useRef(null);
    const boltiveSDK = BoltiveSDK.getInstance();

    useEffect(() => {
        initializeApp();
    }, []);

    const initializeApp = async () => {
        // Initialize Mobile Ads
        await MobileAds().initialize();
        console.log('Mobile Ads initialized');

        // Initialize Boltive SDK
        await initializeBoltive();

        setMonitorStatus('Ready');
    };

    const initializeBoltive = async () => {
        setBoltiveStatus('Initializing...');

        try {
            await boltiveSDK.initialize({
                clientId: Platform.select({
                    ios: 'enhance-epark-sdk-ios', 
                    android: 'enhance-epark-sdk-android'
                }),
                adNetwork: BoltiveAdNetwork.GoogleAdManager
            });

            setBoltiveStatus('Ready');
        } catch (error) {
            console.log('Boltive SDK error:', error);
            setBoltiveStatus('Initialization failed');
        }
    };

    const handleAdLoaded = async () => {
        console.log('Banner ad loaded');
        setIsAdLoaded(true);

        // Capture banner with Boltive after ad is loaded
        await captureBannerWithBoltive();
    };

    const captureBannerWithBoltive = async () => {
        try {
            if (bannerRef.current) {
                const reactTag = findNodeHandle(bannerRef.current);
                if (reactTag) {
                    const tagDetails = {
                        adUnitId: bannerAdUnitId,
                        advertiserId: 'test-advertiser-id',
                        campaignId: 'test-campaign',
                        creativeId: 'test-creative',
                        appName: 'BoltiveDemo'
                    };

                    console.log('Analyzing banner with Boltive...');
                    const result = await boltiveSDK.captureBanner(reactTag, tagDetails);
                    console.log('Boltive analysis result:', result);

                    // Common blocking logic - handle the blocking decision here
                    if (result.shouldBlock) {
                        console.log('Banner should be blocked:', result.reason);
                        
                        // Use React state to hide the banner (common approach)
                        setIsAdBlocked(true);
                        setBlockCount(prevCount => prevCount + 1);
                        setBoltiveStatus('Ready - Ad blocked!');
                    } else {
                        console.log('Banner analysis complete - no blocking needed');
                        setIsAdBlocked(false);
                        setBoltiveStatus('Ready - Ad safe');
                    }
                } else {
                    console.warn('Could not get React tag for banner');
                }
            } else {
                console.warn('Banner ref is null');
            }
        } catch (error) {
            console.error('Failed to analyze banner with Boltive:', error);
            setBoltiveStatus('Ready - Analysis failed');
        }
    };

    const handleAdFailedToLoad = (error) => {
        console.error('Ad failed to load:', error);
        setIsAdLoaded(false);
    };

    const loadAd = () => {
        setIsAdLoaded(false);
        setIsAdBlocked(false);
        setAdKey(prevKey => prevKey + 1);
        setBoltiveStatus('Ready');
    };

    const resetCounter = () => {
        setBlockCount(0);
    };

    return (
        <SafeAreaView style={styles.container}>
            <View style={styles.content}>
                <Text style={styles.title}>Boltive Demo</Text>

                <Text style={styles.status}>
                    Boltive SDK: {boltiveStatus}
                </Text>

                <Text style={styles.status}>
                    Monitor: {monitorStatus}
                </Text>

                <Text style={styles.status}>
                    Ad Status: {isAdLoaded ? 'Loaded' : 'Not Loaded'}
                </Text>

                <View style={styles.counterContainer}>
                    <Text style={styles.counterLabel}>Block Detected:</Text>
                    <Text style={styles.counterValue}>{blockCount}</Text>
                </View>

                <View style={styles.buttonContainer}>
                    <TouchableOpacity style={styles.loadButton} onPress={loadAd}>
                        <Text style={styles.buttonText}>Load Ad</Text>
                    </TouchableOpacity>

                    <TouchableOpacity style={styles.resetButton} onPress={resetCounter}>
                        <Text style={styles.buttonText}>Reset Counter</Text>
                    </TouchableOpacity>
                </View>

                <View style={styles.adContainer}>
                    {!isAdBlocked ? (
                        <BannerAd
                            key={adKey}
                            ref={bannerRef}
                            unitId={bannerAdUnitId}
                            size={BannerAdSize.MEDIUM_RECTANGLE}
                            onAdLoaded={handleAdLoaded}
                            onAdFailedToLoad={handleAdFailedToLoad}
                        />
                    ) : (
                        <View style={styles.blockedAdPlaceholder}>
                            <Text style={styles.blockedAdText}>🛡️ Ad Blocked</Text>
                            <Text style={styles.blockedAdSubtext}>Malicious content detected</Text>
                        </View>
                    )}
                </View>
            </View>
        </SafeAreaView>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#FFFFFF',
    },
    content: {
        flex: 1,
        alignItems: 'center',
        justifyContent: 'center',
        padding: 20,
    },
    title: {
        fontSize: 24,
        fontWeight: 'bold',
        marginBottom: 20,
    },
    status: {
        fontSize: 16,
        marginBottom: 10,
        color: '#666666',
        textAlign: 'center',
    },
    counterContainer: {
        flexDirection: 'row',
        alignItems: 'center',
        marginBottom: 20,
        paddingHorizontal: 20,
        paddingVertical: 10,
        backgroundColor: '#F0F0F0',
        borderRadius: 8,
    },
    counterLabel: {
        fontSize: 18,
        fontWeight: '600',
        color: '#333333',
        marginRight: 10,
    },
    counterValue: {
        fontSize: 24,
        fontWeight: 'bold',
        color: '#FF3B30',
        minWidth: 30,
        textAlign: 'center',
    },
    buttonContainer: {
        flexDirection: 'row',
        gap: 10,
        marginBottom: 30,
    },
    loadButton: {
        backgroundColor: '#007AFF',
        paddingHorizontal: 20,
        paddingVertical: 12,
        borderRadius: 8,
    },
    resetButton: {
        backgroundColor: '#FF9500',
        paddingHorizontal: 20,
        paddingVertical: 12,
        borderRadius: 8,
    },
    buttonText: {
        color: '#FFFFFF',
        fontSize: 16,
        fontWeight: '600',
    },
    adContainer: {
        alignItems: 'center',
        justifyContent: 'center',
        minHeight: 250,
    },
    blockedAdPlaceholder: {
        width: 300,
        height: 250,
        backgroundColor: '#F8F8F8',
        borderWidth: 2,
        borderColor: '#FF3B30',
        borderStyle: 'dashed',
        borderRadius: 8,
        alignItems: 'center',
        justifyContent: 'center',
    },
    blockedAdText: {
        fontSize: 18,
        fontWeight: 'bold',
        color: '#FF3B30',
        marginBottom: 5,
    },
    blockedAdSubtext: {
        fontSize: 14,
        color: '#666666',
        textAlign: 'center',
    },
});

export default App;