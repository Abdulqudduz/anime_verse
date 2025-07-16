import 'dart:collection';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

class LoadingView extends StatefulWidget {
  static const loadingContentKey = ValueKey('loading');
  static const errorContentKey = ValueKey('error');
  static const successContentKey = ValueKey('success');

  static const successContentAnimationDuration = Duration(milliseconds: 400);

  const LoadingView({
    super.key,
    required this.status,
    required this.loadingContent,
    required this.errorContent,
    required this.successContent,
  });

  final LoadingStatus status;
  final Widget loadingContent;
  final Widget errorContent;
  final Widget successContent;

  @override
  State<LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView>
    with TickerProviderStateMixin {
  late final AnimationController _loadingController;
  late final AnimationController _errorController;
  late final AnimationController _successController;

  final Queue<ValueGetter<TickerFuture>> _animationStack = Queue();

  @override
  void initState() {
    super.initState();

    _loadingController =
        _createController(duration: const Duration(milliseconds: 350));
    _errorController =
        _createController(duration: const Duration(milliseconds: 350));
    _successController = _createController(
        duration: LoadingView.successContentAnimationDuration);

    _animationStack.add(_getForwardAnimation(widget.status));
    _playAnimations();
  }

  AnimationController _createController({required Duration duration}) {
    return AnimationController(vsync: this, duration: duration);
  }

  ValueGetter<TickerFuture> _getForwardAnimation(LoadingStatus status) {
    switch (status) {
      case LoadingStatus.idle:
      case LoadingStatus.loading:
        return _loadingController.forward;
      case LoadingStatus.error:
        return _errorController.forward;
      case LoadingStatus.success:
        return _successController.forward;
    }
  }

  ValueGetter<TickerFuture> _getReverseAnimation(LoadingStatus status) {
    switch (status) {
      case LoadingStatus.idle:
      case LoadingStatus.loading:
        return _loadingController.reverse;
      case LoadingStatus.error:
        return _errorController.reverse;
      case LoadingStatus.success:
        return _successController.reverse;
    }
  }

  @override
  void didUpdateWidget(covariant LoadingView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.status != widget.status) {
      _animationStack.add(_getReverseAnimation(oldWidget.status));
      _animationStack.add(_getForwardAnimation(widget.status));
      _playAnimations();
    }
  }

  @override
  void dispose() {
    _loadingController.dispose();
    _errorController.dispose();
    _successController.dispose();
    super.dispose();
  }

  Future<void> _playAnimations() async {
    while (_animationStack.isNotEmpty) {
      await _animationStack.removeFirst()();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _TransitionAnimation(
          key: LoadingView.loadingContentKey,
          controller: _loadingController,
          child: widget.loadingContent,
          isVisible: widget.status == LoadingStatus.loading,
        ),
        _TransitionAnimation(
          key: LoadingView.errorContentKey,
          controller: _errorController,
          child: widget.errorContent,
          isVisible: widget.status == LoadingStatus.error,
        ),
        _TransitionAnimation(
          key: LoadingView.successContentKey,
          controller: _successController,
          child: widget.successContent,
          isVisible: widget.status == LoadingStatus.success,
        ),
      ],
    );
  }
}

class _TransitionAnimation extends StatelessWidget {
  _TransitionAnimation({
    required Key key,
    required this.controller,
    required this.child,
    required this.isVisible,
  })  : _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0.0, 0.65, curve: Curves.ease),
          ),
        ),
        _yTranslation = Tween<double>(begin: 40.0, end: 0.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0.0, 0.65, curve: Curves.ease),
          ),
        ),
        super(key: key);

  final AnimationController controller;
  final Widget child;
  final bool isVisible;

  final Animation<double> _opacity;
  final Animation<double> _yTranslation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return _opacity.value == 0.0
            ? const SizedBox.shrink()
            : IgnorePointer(
                ignoring: !isVisible,
                child: Transform.translate(
                  offset: Offset(0.0, _yTranslation.value),
                  child: Opacity(
                    opacity: _opacity.value,
                    child: child,
                  ),
                ),
              );
      },
    );
  }
}
