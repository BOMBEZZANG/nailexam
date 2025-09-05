import 'dart:ui';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../core/utils/logger.dart';

class AdManager {
  static final AdManager _instance = AdManager._internal();
  static AdManager get instance => _instance;

  AdManager._internal();

  AppOpenAd? _appOpenAd;
  RewardedAd? _rewardedAd;
  bool _isShowingAd = false;
  DateTime? _appOpenLoadTime;
  DateTime? _rewardedAdLoadTime;

  // Test Ad Unit IDs (for development)
  static const String _appOpenAdUnitId =
      'ca-app-pub-3940256099942544/9257395921';
  static const String _rewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';

  // Production Ad Unit IDs (replace with your actual ad unit IDs when ready)
  // static const String _appOpenAdUnitId = Platform.isAndroid
  //     ? 'ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy'
  //     : 'ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy';

  Future<void> initialize() async {
    try {
      // Request configuration for test ads
      final RequestConfiguration requestConfiguration = RequestConfiguration(
        testDeviceIds: ['6F0BB9EE24AB32A40AFF36E6E62333D4'], // From logs
      );
      MobileAds.instance.updateRequestConfiguration(requestConfiguration);
      
      await MobileAds.instance.initialize();
      Logger.i('AdMob initialized successfully');
      
      // Try multiple times with increasing delays for WebView readiness
      await _loadAppOpenAdWithRetry();
      await _loadRewardedAdWithRetry();
    } catch (e) {
      Logger.e('Failed to initialize AdMob', error: e);
    }
  }

  Future<void> _loadAppOpenAdWithRetry() async {
    int attempts = 0;
    const maxAttempts = 3;
    
    while (attempts < maxAttempts && _appOpenAd == null) {
      attempts++;
      final delay = Duration(seconds: 2 * attempts); // 2s, 4s, 6s
      Logger.i('Attempting to load ad (attempt $attempts/$maxAttempts) after ${delay.inSeconds}s delay');
      
      await Future.delayed(delay);
      _loadAppOpenAd();
      
      // Wait to see if ad loads successfully
      await Future.delayed(const Duration(seconds: 3));
      
      if (_appOpenAd != null) {
        Logger.i('Ad loaded successfully on attempt $attempts');
        break;
      } else {
        Logger.w('Ad failed to load on attempt $attempts');
      }
    }
    
    if (_appOpenAd == null) {
      Logger.w('Failed to load app open ad after $maxAttempts attempts');
    }
  }

  Future<void> _loadRewardedAdWithRetry() async {
    int attempts = 0;
    const maxAttempts = 3;
    
    while (attempts < maxAttempts && _rewardedAd == null) {
      attempts++;
      final delay = Duration(seconds: 2 * attempts);
      Logger.i('Attempting to load rewarded ad (attempt $attempts/$maxAttempts) after ${delay.inSeconds}s delay');
      
      await Future.delayed(delay);
      _loadRewardedAd();
      
      // Wait to see if ad loads successfully
      await Future.delayed(const Duration(seconds: 3));
      
      if (_rewardedAd != null) {
        Logger.i('Rewarded ad loaded successfully on attempt $attempts');
        break;
      } else {
        Logger.w('Rewarded ad failed to load on attempt $attempts');
      }
    }
    
    if (_rewardedAd == null) {
      Logger.w('Failed to load rewarded ad after $maxAttempts attempts');
    }
  }

  void _loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: _appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          Logger.i('App open ad loaded successfully');
          _appOpenLoadTime = DateTime.now();
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (error) {
          Logger.e('Failed to load app open ad: ${error.message} (Code: ${error.code})');
          _appOpenAd = null;
        },
      ),
    );
  }

  bool get isAdAvailable {
    return _appOpenAd != null && !_isAdExpired();
  }

  bool _isAdExpired() {
    if (_appOpenLoadTime == null) return true;
    return DateTime.now().difference(_appOpenLoadTime!).inHours >= 4;
  }

  Future<void> showAppOpenAd({
    VoidCallback? onAdShown,
    VoidCallback? onAdDismissed,
    VoidCallback? onAdFailedToShow,
  }) async {
    if (!isAdAvailable || _isShowingAd) {
      Logger.w('App open ad is not available or already showing');
      onAdFailedToShow?.call();
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        Logger.i('App open ad showed full screen content');
        _isShowingAd = true;
        onAdShown?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        Logger.e('App open ad failed to show', error: error);
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        _loadAppOpenAd(); // Load a new ad
        onAdFailedToShow?.call();
      },
      onAdDismissedFullScreenContent: (ad) {
        Logger.i('App open ad dismissed');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        _loadAppOpenAd(); // Load a new ad
        onAdDismissed?.call();
      },
    );

    try {
      await _appOpenAd!.show();
    } catch (e) {
      Logger.e('Error showing app open ad', error: e);
      _isShowingAd = false;
      onAdFailedToShow?.call();
    }
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          Logger.i('Rewarded ad loaded successfully');
          _rewardedAdLoadTime = DateTime.now();
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          Logger.e('Failed to load rewarded ad: ${error.message} (Code: ${error.code})');
          _rewardedAd = null;
        },
      ),
    );
  }

  bool get isRewardedAdAvailable {
    return _rewardedAd != null && !_isRewardedAdExpired();
  }

  bool _isRewardedAdExpired() {
    if (_rewardedAdLoadTime == null) return true;
    return DateTime.now().difference(_rewardedAdLoadTime!).inHours >= 1;
  }

  Future<void> showRewardedAd({
    VoidCallback? onAdShown,
    VoidCallback? onUserEarnedReward,
    VoidCallback? onAdDismissed,
    VoidCallback? onAdFailedToShow,
  }) async {
    if (!isRewardedAdAvailable || _isShowingAd) {
      Logger.w('Rewarded ad is not available or already showing');
      onAdFailedToShow?.call();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        Logger.i('Rewarded ad showed full screen content');
        _isShowingAd = true;
        onAdShown?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        Logger.e('Rewarded ad failed to show', error: error);
        _isShowingAd = false;
        ad.dispose();
        _rewardedAd = null;
        _loadRewardedAd(); // Load a new ad
        onAdFailedToShow?.call();
      },
      onAdDismissedFullScreenContent: (ad) {
        Logger.i('Rewarded ad dismissed');
        _isShowingAd = false;
        ad.dispose();
        _rewardedAd = null;
        _loadRewardedAd(); // Load a new ad
        onAdDismissed?.call();
      },
    );

    try {
      await _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
        Logger.i('User earned reward: ${reward.amount} ${reward.type}');
        onUserEarnedReward?.call();
      });
    } catch (e) {
      Logger.e('Error showing rewarded ad', error: e);
      _isShowingAd = false;
      onAdFailedToShow?.call();
    }
  }

  void dispose() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
