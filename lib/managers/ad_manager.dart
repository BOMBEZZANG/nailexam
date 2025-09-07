import 'dart:async';
import 'dart:ui';
import 'dart:io';
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
  bool _isInitialized = false;

  // Production Ad Unit IDs - iOS
  static const String _iosAppOpenAdUnitId =
      'ca-app-pub-2598779635969436/1666123548';
  static const String _iosRewardedAdUnitId =
      'ca-app-pub-2598779635969436/5672531759';
  static const String _iosInterstitialAdUnitId =
      'ca-app-pub-2598779635969436/4184475678';
  static const String _iosBannerAdUnitId =
      'ca-app-pub-2598779635969436/3565243160';

  // Test Ad Unit IDs - for development and Android (until Android production IDs are provided)
  static const String _testAppOpenAdUnitId =
      'ca-app-pub-3940256099942544/9257395921';
  static const String _testRewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _testBannerAdUnitId =
      'ca-app-pub-3940256099942544/2435281174';
  static const String _testInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/4411468910';

  // Platform-specific getters
  static String get _appOpenAdUnitId =>
      Platform.isIOS ? _iosAppOpenAdUnitId : _testAppOpenAdUnitId;
  static String get _rewardedAdUnitId =>
      Platform.isIOS ? _iosRewardedAdUnitId : _testRewardedAdUnitId;
  static String get _bannerAdUnitId =>
      Platform.isIOS ? _iosBannerAdUnitId : _testBannerAdUnitId;
  static String get _interstitialAdUnitId =>
      Platform.isIOS ? _iosInterstitialAdUnitId : _testInterstitialAdUnitId;

  Future<void> initialize() async {
    if (_isInitialized) {
      Logger.i('AdMob already initialized');
      return;
    }

    try {
      Logger.i('Starting AdMob initialization...');
      
      // Configure test devices for debugging (can be removed for production release)
      final RequestConfiguration requestConfiguration = RequestConfiguration(
        testDeviceIds: ['23188363bf574ddb85daa964a6ab437d'], // From your logs
      );
      MobileAds.instance.updateRequestConfiguration(requestConfiguration);
      
      await MobileAds.instance.initialize();
      _isInitialized = true;
      Logger.i('AdMob initialized successfully');
      
      // 광고 로딩을 비동기로 시작 (빠른 초기화를 위해)
      _loadAppOpenAdAsync();
      _loadRewardedAdAsync();
      
    } catch (e) {
      Logger.e('Failed to initialize AdMob', error: e);
      _isInitialized = false;
    }
  }

  // 앱 오픈 광고를 비동기로 로딩 (재시도 로직 간소화)
  Future<void> _loadAppOpenAdAsync() async {
    int attempts = 0;
    const maxAttempts = 2; // 재시도 횟수 감소
    
    while (attempts < maxAttempts && _appOpenAd == null && _isInitialized) {
      attempts++;
      final delay = Duration(milliseconds: 500 * attempts); // 0.5s, 1s로 단축
      
      if (attempts > 1) {
        Logger.i('Retrying app open ad load (attempt $attempts/$maxAttempts) after ${delay.inMilliseconds}ms delay');
        await Future.delayed(delay);
      } else {
        Logger.i('Loading app open ad (attempt $attempts/$maxAttempts)');
      }
      
      await _loadAppOpenAd();
      
      if (_appOpenAd != null) {
        Logger.i('App open ad loaded successfully on attempt $attempts');
        break;
      }
    }
    
    if (_appOpenAd == null) {
      Logger.w('Failed to load app open ad after $maxAttempts attempts');
    }
  }

  // 리워드 광고를 비동기로 로딩 (재시도 로직 간소화)
  Future<void> _loadRewardedAdAsync() async {
    int attempts = 0;
    const maxAttempts = 2; // 재시도 횟수 감소
    
    while (attempts < maxAttempts && _rewardedAd == null && _isInitialized) {
      attempts++;
      final delay = Duration(milliseconds: 500 * attempts); // 0.5s, 1s로 단축
      
      if (attempts > 1) {
        Logger.i('Retrying rewarded ad load (attempt $attempts/$maxAttempts) after ${delay.inMilliseconds}ms delay');
        await Future.delayed(delay);
      } else {
        Logger.i('Loading rewarded ad (attempt $attempts/$maxAttempts)');
      }
      
      await _loadRewardedAd();
      
      if (_rewardedAd != null) {
        Logger.i('Rewarded ad loaded successfully on attempt $attempts');
        break;
      }
    }
    
    if (_rewardedAd == null) {
      Logger.w('Failed to load rewarded ad after $maxAttempts attempts');
    }
  }

  Future<void> _loadAppOpenAd() async {
    try {
      final completer = Completer<void>();
      
      AppOpenAd.load(
        adUnitId: _appOpenAdUnitId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            Logger.i('App open ad loaded successfully');
            _appOpenLoadTime = DateTime.now();
            _appOpenAd = ad;
            completer.complete();
          },
          onAdFailedToLoad: (error) {
            Logger.e('Failed to load app open ad: ${error.message} (Code: ${error.code})');
            _appOpenAd = null;
            completer.complete();
          },
        ),
      );
      
      // 최대 2초 대기 (무한 대기 방지)
      await completer.future.timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          Logger.w('App open ad loading timed out');
        },
      );
    } catch (e) {
      Logger.e('Error loading app open ad', error: e);
    }
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
        _loadAppOpenAdAsync(); // 새 광고 로딩
        onAdFailedToShow?.call();
      },
      onAdDismissedFullScreenContent: (ad) {
        Logger.i('App open ad dismissed');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        _loadAppOpenAdAsync(); // 새 광고 로딩
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

  Future<void> _loadRewardedAd() async {
    try {
      final completer = Completer<void>();
      
      RewardedAd.load(
        adUnitId: _rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            Logger.i('Rewarded ad loaded successfully');
            _rewardedAdLoadTime = DateTime.now();
            _rewardedAd = ad;
            completer.complete();
          },
          onAdFailedToLoad: (error) {
            Logger.e('Failed to load rewarded ad: ${error.message} (Code: ${error.code})');
            _rewardedAd = null;
            completer.complete();
          },
        ),
      );
      
      // 최대 2초 대기 (무한 대기 방지)
      await completer.future.timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          Logger.w('Rewarded ad loading timed out');
        },
      );
    } catch (e) {
      Logger.e('Error loading rewarded ad', error: e);
    }
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
        _loadRewardedAdAsync(); // 새 광고 로딩
        onAdFailedToShow?.call();
      },
      onAdDismissedFullScreenContent: (ad) {
        Logger.i('Rewarded ad dismissed');
        _isShowingAd = false;
        ad.dispose();
        _rewardedAd = null;
        _loadRewardedAdAsync(); // 새 광고 로딩
        onAdDismissed?.call();
      },
    );

    try {
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          Logger.i('User earned reward: ${reward.amount} ${reward.type}');
          onUserEarnedReward?.call();
        },
      );
    } catch (e) {
      Logger.e('Error showing rewarded ad', error: e);
      _isShowingAd = false;
      onAdFailedToShow?.call();
    }
  }

  void dispose() {
    _appOpenAd?.dispose();
    _rewardedAd?.dispose();
    _appOpenAd = null;
    _rewardedAd = null;
    _isInitialized = false;
  }
  
  // Banner ad creation helper
  BannerAd createBannerAd({
    required AdSize size,
    void Function(Ad ad)? onAdLoaded,
    void Function(Ad ad, LoadAdError error)? onAdFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: _bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          Logger.i('Banner ad loaded successfully');
          onAdLoaded?.call(ad);
        },
        onAdFailedToLoad: (ad, error) {
          Logger.e('Banner ad failed to load: ${error.message}');
          ad.dispose();
          onAdFailedToLoad?.call(ad, error);
        },
        onAdOpened: (ad) {
          Logger.i('Banner ad opened');
        },
        onAdClosed: (ad) {
          Logger.i('Banner ad closed');
        },
      ),
    );
  }
  
  // Helper to get test ad unit ID for banner
  String get bannerAdUnitId => _bannerAdUnitId;
}