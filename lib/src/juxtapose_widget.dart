library juxtapose;

import 'dart:math' show min, max;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show SystemMouseCursors;

/// A widget for comparing two stacked widgets by dragging a slider thumb to
/// reveal either sides of the slider.
///
/// Sliding direction can be [Axis.horizontal] or [Axis.vertical].
class Juxtapose extends StatefulWidget {
  /// Background color of the Juxtapose box. Defaults to [Colors.white].
  final Color backgroundColor;

  // /// [StackFit.expand] stretches the [foregroundWidget]
  // /// and [backgroundWidget] widgets to fill up all the space.
  // ///
  // /// [StackFit.loose] passes loose constraints to the [foregroundWidget]
  // /// and [backgroundWidget] widgets.
  // ///
  // /// Dfaults to [StackFit.expand].
  // final StackFit fit;

  /// Sliding direction for juxtaposing between the two widgets.
  ///
  /// Defaults to [Axis.horizontal].
  final Axis direction;

  /// The foreground widget is displayed in front of the [backgroundWidget].
  final Widget foregroundWidget;

  /// The background widget is displayed behind the [foregroundWidget].
  final Widget backgroundWidget;

  /// The color of the horizontal/vertical divider
  /// between the two frames/widgets.
  ///
  /// Defaults to [Colors.white].
  final Color dividerColor;

  /// The line thickness of the horizontal/vertical divider
  /// between the two frames/widgets.
  ///
  /// Defaults to 3.0.
  final double dividerThickness;

  /// Color of the thumb that is dragged to juxtapose.
  ///
  /// Defaults to [Colors.white].
  final Color thumbColor;

  /// Size width is the shortest side.
  ///
  /// Size height is the longest side.
  ///
  /// The height and width should all be greater than 12.0.
  ///
  /// Defaults to ```Size(12, 100)```.
  final Size thumbSize;

  /// Sets the [BorderRadius] of the thumb widget.
  ///
  /// Defaults to ```BorderRadius.circular(4)```.
  final BorderRadius thumbBorderRadius;

  /// Height of the Juxtapose box.
  final double height;

  /// Width of the Juxtapose box.
  final double width;

  /// Indicates whether the arrows on the sides of the thumb
  /// are shown or not.
  final bool showArrows;

  /// Creates a Juxtapose widget.
  ///
  /// This widget simply is used to compare two stacked frames/widgets
  /// by dragging or sliding the thumb based on the set [direction].
  ///
  /// [direction] can be [Axis.horizontal] or [Axis.vertical].
  ///
  /// Default [direction] is [Axis.horizontal].
  Juxtapose({
    Key key,
    @required this.backgroundWidget,
    @required this.foregroundWidget,
    // this.fit = StackFit.expand,
    this.dividerColor = Colors.white,
    this.thumbColor = Colors.white,
    this.dividerThickness = 3,
    this.thumbSize = const Size(12, 100),
    this.direction = Axis.horizontal,
    this.height,
    this.width,
    this.thumbBorderRadius,
    this.showArrows = true,
    this.backgroundColor = Colors.transparent,
  })  : assert((thumbSize?.width ?? 0) >= 12 || (thumbSize?.height ?? 0) >= 12),
        super(key: key);

  @override
  _JuxtaposeState createState() => _JuxtaposeState();
}

class _JuxtaposeState extends State<Juxtapose> {
  bool _initialised = false;
  Offset _position = Offset(0, 0);
  double _kIconSize = 24.0;
  BoxConstraints _cachedConstraints;

  double get _iconSize => widget.showArrows ? _kIconSize : 0.0;

  bool get _isHorizontal => widget.direction == Axis.horizontal;

  Size get _thumbSize {
    final s = widget.thumbSize;
    return _isHorizontal ? Size(s.width, s.height) : Size(s.height, s.width);
  }

  double get _touchWidth {
    return _isHorizontal ? widget.dividerThickness + _thumbSize.width : null;
  }

  double get _touchHeight {
    return !_isHorizontal ? widget.dividerThickness + _thumbSize.height : null;
  }

  double get _horizontalArrowOffset => _isHorizontal ? _iconSize : 0.0;

  double get _verticalArrowOffset => !_isHorizontal ? _iconSize : 0.0;

  Offset _safeHOffset(Offset offset, BoxConstraints constraints) {
    final _p = widget.dividerThickness + 10;
    final _min = min(offset.dx, constraints.maxWidth - _thumbSize.width - _p);
    return Offset(max(_isHorizontal ? 10.0 : 0.0, _min), 0.0);
  }

  Offset _safeVOffset(Offset offset, BoxConstraints constraints, EdgeInsets m) {
    final _padding = 30.0;
    final _min = min(offset.dy, (constraints.maxHeight - _padding) - m.bottom);
    return Offset(0.0, max(_min, _isHorizontal ? 0.0 : (m.top + _padding)));
  }

  Widget _horizontalThumb() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.showArrows)
          Icon(Icons.arrow_left, color: widget.thumbColor, size: _iconSize),
        Container(
          height: _thumbSize.height,
          width: _thumbSize.width,
          decoration: BoxDecoration(
            color: widget.thumbColor,
            borderRadius: widget.thumbBorderRadius ?? BorderRadius.circular(4),
            boxShadow: const [BoxShadow()],
          ),
        ),
        if (widget.showArrows)
          Icon(Icons.arrow_right, color: widget.thumbColor, size: _iconSize),
      ],
    );
  }

  Widget _verticalThumb() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.showArrows)
          Icon(Icons.arrow_drop_up, color: widget.thumbColor, size: _iconSize),
        Container(
          height: _thumbSize.height,
          width: _thumbSize.width,
          decoration: BoxDecoration(
            color: widget.thumbColor,
            borderRadius: widget.thumbBorderRadius ?? BorderRadius.circular(4),
            boxShadow: const [BoxShadow()],
          ),
        ),
        if (widget.showArrows)
          Icon(
            Icons.arrow_drop_down,
            color: widget.thumbColor,
            size: _iconSize,
          ),
      ],
    );
  }

  @override
  void didUpdateWidget(Juxtapose oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget != widget) setState(() => _initialised = false);
  }

  @override
  Widget build(BuildContext context) {
    final _viewInsets = MediaQuery.of(context).padding;
    return Material(
      color: widget.backgroundColor,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Align(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final _width = constraints.maxWidth;
              final _height = constraints.maxHeight;

              if (_cachedConstraints != constraints) _initialised = false;

              if (!_initialised) {
                _initialised = true;
                _cachedConstraints = constraints;
                if (_isHorizontal) {
                  _position = Offset((_width / 2), 0);
                } else {
                  _position = Offset(0, (_height / 2));
                }
              }
              return Stack(
                // fit: widget.fit,
                fit: StackFit.expand,
                alignment: AlignmentDirectional.center,
                children: [
                  widget.backgroundWidget,
                  ClipPath(
                    child: widget.foregroundWidget,
                    clipper: _JuxtaposeClipper(
                      offset: _position,
                      isHorizontal: _isHorizontal,
                      thumbSize: _thumbSize,
                    ),
                  ),
                  Positioned(
                    left: _position.dx - _horizontalArrowOffset,
                    top: _position.dy - _verticalArrowOffset,
                    child: MouseRegion(
                      cursor: _isHorizontal
                          ? SystemMouseCursors.resizeColumn
                          : SystemMouseCursors.resizeRow,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: _isHorizontal
                                ? widget.dividerThickness
                                : _width,
                            height: _isHorizontal
                                ? _height
                                : widget.dividerThickness,
                            decoration: BoxDecoration(
                              color: widget.dividerColor,
                              boxShadow: const [BoxShadow()],
                            ),
                          ),
                          _isHorizontal ? _horizontalThumb() : _verticalThumb()
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      dragStartBehavior: DragStartBehavior.down,
                      onHorizontalDragDown: (_) => _initialised = true,
                      onVerticalDragDown: (_) => _initialised = true,
                      onHorizontalDragUpdate: (details) {
                        if (!_isHorizontal) return;
                        setState(() {
                          _position = _safeHOffset(
                            details.localPosition,
                            constraints,
                          );
                        });
                      },
                      onVerticalDragUpdate: (details) {
                        if (_isHorizontal) return;
                        setState(() {
                          _position = _safeVOffset(
                            details.localPosition,
                            constraints,
                            _viewInsets,
                          );
                        });
                      },
                      child: SizedBox(width: _touchWidth, height: _touchHeight),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _JuxtaposeClipper extends CustomClipper<Path> {
  final bool isHorizontal;
  final Offset offset;
  final Size thumbSize;

  _JuxtaposeClipper({
    @required this.isHorizontal,
    @required this.offset,
    @required this.thumbSize,
  });

  @override
  Path getClip(Size size) {
    final path = new Path();
    if (isHorizontal) {
      path.addRect(
        Rect.fromLTWH(0, 0, offset.dx + (thumbSize.width / 2), size.height),
      );
    } else {
      path.addRect(
        Rect.fromLTWH(0, 0, size.width, offset.dy + (thumbSize.height / 2)),
      );
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
