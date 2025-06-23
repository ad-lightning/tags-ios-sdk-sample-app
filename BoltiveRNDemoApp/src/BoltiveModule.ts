import { NativeModules } from 'react-native';

export enum BoltiveAdNetwork {
    GoogleAdManager = 'GoogleAdManager',
    AppLovin = 'AppLovin',
    AdMob = 'AdMob',
}

export interface BoltiveTagDetails {
    adUnitId?: string;
    advertiserId?: string;
    campaignId?: string;
    creativeId?: string;
    lineItemId?: string;
    sspRefreshCode?: string;
    appName?: string;
}

export interface BoltiveConfiguration {
    clientId: string;
    adNetwork: BoltiveAdNetwork | string;
}

const { BoltiveModule } = NativeModules;

class BoltiveSDK {
    private static instance: BoltiveSDK;
    private isInitialized = false;

    private constructor() {}

    public static getInstance(): BoltiveSDK {
        if (!BoltiveSDK.instance) {
            BoltiveSDK.instance = new BoltiveSDK();
        }
        return BoltiveSDK.instance;
    }

    public async initialize(configuration: BoltiveConfiguration): Promise<void> {
        try {
            await BoltiveModule.initialize(configuration.clientId, configuration.adNetwork);
            this.isInitialized = true;
        } catch (error) {
            throw new Error(`Failed to initialize Boltive SDK: ${error}`);
        }
    }

    public async getSDKVersion(): Promise<string> {
        return BoltiveModule.getSDKVersion();
    }

    public async captureBanner(reactTag: number, tagDetails: BoltiveTagDetails): Promise<string> {
        if (!this.isInitialized) {
            throw new Error('Boltive SDK not initialized. Call initialize() first.');
        }
        return BoltiveModule.captureBanner(reactTag, tagDetails);
    }
}

export default BoltiveSDK;