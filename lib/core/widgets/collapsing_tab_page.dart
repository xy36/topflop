import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Page of a main tab with a collapsing header.
///
/// Expanded: app name with gear icon, large title with [action] and below
/// that optionally more rows ([below], e.g. search and chips). When
/// scrolling down everything slides under a slim bar, into which a small
/// title and the [action] then fade in. "Quick return": when
/// scrolling up the header comes back immediately and at the end snaps fully
/// in or fully out – depending on the overall direction of the gesture.
class CollapsingTabPage extends StatefulWidget {
  const CollapsingTabPage({
    super.key,
    required this.title,
    required this.action,
    required this.slivers,
    this.below = const [],
  });

  final String title;
  final Widget action;

  /// Rows below the title with a fixed height, e.g. `(searchField, 52)`.
  final List<(Widget, double)> below;

  /// Page content; the page itself handles spacing to the header and navigation.
  final List<Widget> slivers;

  @override
  State<CollapsingTabPage> createState() => _CollapsingTabPageState();
}

class _CollapsingTabPageState extends State<CollapsingTabPage> with SingleTickerProviderStateMixin {
  /// How many pixels of the header area are currently collapsed.
  late final _hidden = AnimationController.unbounded(vsync: this);

  /// Maximum collapsible height (everything except the top bar).
  double _range = 0;
  double _gestureStart = 0;

  /// Scroll position; when content is under the header, it gets a shadow.
  double _pixels = 0;

  @override
  void dispose() {
    _hidden.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification n) {
    if (n.depth != 0 || n.metrics.axis != Axis.vertical) return false;
    final pixels = n.metrics.pixels;
    _pixels = pixels;
    final limit = pixels.clamp(0.0, _range);
    if (n is ScrollStartNotification) {
      _hidden.stop();
      _gestureStart = pixels;
    } else if (n is ScrollUpdateNotification) {
      _hidden.value = (_hidden.value + (n.scrollDelta ?? 0)).clamp(0.0, limit);
    } else if (n is ScrollEndNotification) {
      final value = _hidden.value;
      if (value > 0 && value < limit) {
        final scrolledUp = pixels < _gestureStart;
        _hidden.animateTo(
          scrolledUp ? 0 : limit,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final header = _Header(
      title: widget.title,
      appName: l10n.appName.toUpperCase(),
      settingsTooltip: l10n.settings,
      action: widget.action,
      below: widget.below,
    );
    _range = header.maxExtent - header.minExtent;

    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverToBoxAdapter(child: SizedBox(height: header.maxExtent)),
                ...widget.slivers,
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _hidden,
              builder: (context, _) {
                final hidden = _hidden.value.clamp(0.0, _range);
                return SizedBox(
                  height: header.maxExtent - hidden,
                  child: header.build(context, hidden, scrolledUnder: _pixels > hidden + 1),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Header {
  _Header({
    required this.title,
    required this.appName,
    required this.settingsTooltip,
    required this.action,
    required this.below,
  });

  final String title;
  final String appName;
  final String settingsTooltip;
  final Widget action;
  final List<(Widget, double)> below;

  static const _bar = 52.0; // 8 spacing + 44 bar
  static const _titleRow = 56.0;
  static const _gap = 16.0;
  static const _bottom = 8.0;

  double get _body => _titleRow + below.fold(0.0, (sum, row) => sum + _gap + row.$2) + _bottom;

  double get maxExtent => _bar + _body;

  double get minExtent => _bar + _bottom;

  Widget build(BuildContext context, double shrinkOffset, {bool scrolledUnder = false}) {
    // 0 = large title visible, 1 = title has disappeared under the bar.
    final t = Curves.easeOut.transform((shrinkOffset / (_titleRow * 0.8)).clamp(0.0, 1.0));
    final collapsed = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.background,
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow.withValues(
              alpha: (scrolledUnder ? 0.08 : 0.08 * collapsed) * (context.colors.isDark ? 3 : 1),
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRect(
        child: Stack(
          children: [
            // Content slides under the bar, anchored at the bottom.
            Positioned(
              left: 0,
              right: 0,
              top: _bar - shrinkOffset,
              height: _body,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: _titleRow,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Opacity(
                        opacity: 1 - t,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: AppText.display(32),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IgnorePointer(ignoring: t > 0.5, child: action),
                          ],
                        ),
                      ),
                    ),
                  ),
                  for (final (child, height) in below) ...[
                    const SizedBox(height: _gap),
                    SizedBox(height: height, child: child),
                  ],
                ],
              ),
            ),
            // Top bar, always visible.
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: _bar,
              child: ColoredBox(
                color: context.colors.background,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            Opacity(
                              opacity: 1 - t,
                              child: Text(
                                appName,
                                style: AppText.overline(color: context.colors.muted)
                                    .copyWith(fontSize: 12, letterSpacing: 1.4),
                              ),
                            ),
                            Opacity(
                              opacity: t,
                              child: Transform.translate(
                                offset: Offset(0, 8 * (1 - t)),
                                child: Text(
                                  title,
                                  style: AppText.display(20),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IgnorePointer(
                        ignoring: t < 0.5,
                        child: Opacity(
                          opacity: t,
                          child: Transform.scale(scale: 0.85 + 0.15 * t, child: action),
                        ),
                      ),
                      SizedBox(width: 8 * t),
                      SizedBox(
                        width: 44,
                        child: IconButton(
                          onPressed: () => context.push('/settings'),
                          tooltip: settingsTooltip,
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.settings_outlined, size: 22, color: context.colors.muted),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
