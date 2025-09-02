import 'package:flutter/foundation.dart';

abstract class BasePresenter<V extends BaseView> {
  V? _view;
  
  V? get view => _view;
  
  bool get isViewAttached => _view != null;
  
  void attachView(V view) {
    _view = view;
    onViewAttached();
  }
  
  void detachView() {
    onViewDetached();
    _view = null;
  }
  
  @protected
  void onViewAttached() {}
  
  @protected
  void onViewDetached() {}
  
  void dispose() {
    detachView();
  }
}

abstract class BaseView {
  void showLoading();
  void hideLoading();
  void showError(String message);
  void showSuccess(String message);
}