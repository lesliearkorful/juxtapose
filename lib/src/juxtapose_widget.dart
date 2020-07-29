library juxtapose;

import 'dart:math' show min, max;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show SystemMouseCursors;

/// Creates a Juxtapose widget
///
/// This widget simply is used to compare two stacked frames/widgets
/// by dragging or sliding the thumb based on the set [direction].
///
/// [direction] can be [Axis.horizontal] or [Axis.vertical]
class Juxtapose extends StatefulWidget {
  /// [StackFit.expand] stretches the [foreground]
  /// and [background] widgets to fill up all the space
  ///
  /// [StackFit.loose] passes loose constraints to the [foreground]
  /// and [background] widgets
  ///
  /// Dfaults to [StackFit.expand]
  final StackFit fit;

  /// Sliding direction for juxtaposing between the two widgets
  ///
  /// Defaults to [Axis.horizontal]
  final Axis direction;

  /// The foreground widget is displayed in front of the [backgroundWidget]
  final Widget foregroundWidget;

  /// The background widget is displayed behind the [foregroundWidget]
  final Widget backgroundWidget;

  /// The color of the horizontal/vertical divider
  /// between the two frames/widgets
  ///
  /// Defaults to [Colors.white]
  final Color dividerColor;

  /// The line thickness of the horizontal/vertical divider
  /// between the two frames/widgets
  ///
  /// Defaults to ```3```
  final double dividerThickness;

  /// Color of the thumb that is dragged to juxtapose
  ///
  /// Defaults to [Colors.white]
  final Color thumbColor;

  /// Size width is the shortest side
  /// Size height is the longest side
  ///
  /// The height and width should all be greater than 12.0
  ///
  /// Defaults to ```Size(12, 100)```
  final Size thumbSize;

  /// Sets the [borderRadius] of the thumb widget
  ///
  /// Defaults to [BorderRadius.circular(4)]
  final BorderRadius thumbBorderRadius;

  /// Height of the Juxtapose box
  final double height;

  /// Width of the Juxtapose box
  final double width;

  Juxtapose({
    Key key,
    @required this.backgroundWidget,
    @required this.foregroundWidget,
    this.fit = StackFit.expand,
    this.dividerColor = Colors.white,
    this.thumbColor = Colors.white,
    this.dividerThickness = 3,
    this.thumbSize = const Size(12, 100),
    this.direction = Axis.horizontal,
    this.height,
    this.width,
    this.thumbBorderRadius,
  })  : assert((thumbSize?.width ?? 0) >= 12 || (thumbSize?.height ?? 0) >= 12),
        super(key: key);

  @override
  _JuxtaposeState createState() => _JuxtaposeState();
}

class _JuxtaposeState extends State<Juxtapose> {
  bool _initialised = false;
  Offset _position = Offset(0, 0);
  // bool _hideHint = false;=

  bool get _isHorizontal => widget.direction == Axis.horizontal;

  Size get _thumbSize {
    final s = widget.thumbSize;
    return _isHorizontal ? Size(s.width, s.height) : Size(s.height, s.width);
  }

  Widget get _defaultButton => Container(
        height: _thumbSize.height,
        width: _thumbSize.width,
        decoration: BoxDecoration(
          color: widget.thumbColor,
          borderRadius: widget.thumbBorderRadius ?? BorderRadius.circular(4),
          boxShadow: const [BoxShadow()],
        ),
      );

  Offset _safeHOffset(Offset offset, BoxConstraints constraints) {
    final _p = 10.0;
    final _min = min(offset.dx, constraints.maxWidth - _thumbSize.width - _p);
    return Offset(max(_isHorizontal ? _p : 0.0, _min), 0.0);
  }

  Offset _safeVOffset(Offset offset, BoxConstraints constraints, EdgeInsets m) {
    final _padding = 30.0;
    final _min = min(offset.dy, (constraints.maxHeight - _padding) - m.bottom);
    return Offset(0.0, max(_min, _isHorizontal ? 0.0 : (m.top + _padding)));
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
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Align(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final _width = constraints.maxWidth;
              final _height = constraints.maxHeight;

              if (!_initialised) {
                _initialised = true;
                if (_isHorizontal)
                  _position = Offset((_width / 2), 0);
                else
                  _position = Offset(0, (_height / 2));
              }
              return Stack(
                fit: widget.fit,
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
                    left: _safeHOffset(_position, constraints).dx,
                    top: _safeVOffset(_position, constraints, _viewInsets).dy,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      dragStartBehavior: DragStartBehavior.down,
                      onHorizontalDragDown: (_) => _initialised = true,
                      onVerticalDragDown: (_) => _initialised = true,
                      onHorizontalDragUpdate: (details) {
                        if (!_isHorizontal) return;
                        setState(() {
                          _position = _safeHOffset(
                            details.globalPosition,
                            constraints,
                          );
                        });
                      },
                      onVerticalDragUpdate: (details) {
                        if (_isHorizontal) return;
                        setState(() {
                          _position = _safeVOffset(
                            details.globalPosition,
                            constraints,
                            _viewInsets,
                          );
                        });
                      },
                      child: MouseRegion(
                        cursor: _isHorizontal
                            ? SystemMouseCursors.horizontalDoubleArrow
                            : SystemMouseCursors.verticalDoubleArrow,
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
                            _defaultButton,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // if (!_hideHint)
                  //   Align(
                  //     alignment: Alignment.center,
                  //     child: Container(
                  //       margin: EdgeInsets.only(top: _thumbSize.height + 40),
                  //       padding: _isHorizontal
                  //           ? EdgeInsets.all(5)
                  //           : EdgeInsets.fromLTRB(20, 0, 20, 0),
                  //       decoration: BoxDecoration(
                  //         color: Colors.black87,
                  //         borderRadius: BorderRadius.circular(8),
                  //       ),
                  //       child: _isHorizontal ? _horizontalHint : _verticalHint,
                  //     ),
                  //   ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // final _horizontalHint = Row(
  //   mainAxisSize: MainAxisSize.min,
  //   mainAxisAlignment: MainAxisAlignment.center,
  //   children: [
  //     Icon(Icons.arrow_left, color: Colors.white),
  //     Text(
  //       "Slide Bar Horizontally",
  //       style: TextStyle(color: Colors.white),
  //     ),
  //     Icon(Icons.arrow_right, color: Colors.white),
  //   ],
  // );

  // final _verticalHint = Column(
  //   mainAxisSize: MainAxisSize.min,
  //   mainAxisAlignment: MainAxisAlignment.center,
  //   children: [
  //     Icon(Icons.arrow_drop_up, color: Colors.white),
  //     Text(
  //       "Slide Bar Vertically",
  //       style: TextStyle(color: Colors.white),
  //     ),
  //     Icon(Icons.arrow_drop_down, color: Colors.white),
  //   ],
  // );
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
