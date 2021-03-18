import 'dart:async';

import 'package:flutter/material.dart';

/// Function typedef for the [TickBuilder] builder callback.
typedef TickerBuilderBuilder = Widget Function(BuildContext context, int index);

///
typedef OnTick = void Function(int index);

///
/// Acts as a timing source which causes a subtree rebuild on every tick.
///
/// The builder is called each interval and is passed the tick count.
///
/// The tick count is incremented each interval until it reaches the limit
/// after which it is reset to zero.
/// The default limit is null which means no limit.
class TickBuilder extends StatefulWidget {
  final TickerBuilderBuilder _builder;
  final Duration _interval;
  final int _limit;
  final bool _active;

  /// Create a TickBuilder
  /// [interval] is the time between each tick. We could the [builder]
  ///  for each tick.
  /// [limit] the tick count will reset when we hit the limit.
  /// If limit is -1 then it will increment forever.
  /// If [active] is false the tick builder will stop ticking.
  const TickBuilder(
      {Key? key,
      required TickerBuilderBuilder builder,
      required Duration interval,
      int limit = -1,
      bool active = true})
      : _builder = builder,
        _interval = interval,
        _limit = limit,
        _active = active,
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TickBuilderState();
  }
}

class _TickBuilderState extends State<TickBuilder> {
  int tickCount = 0;

  @override
  void initState() {
    super.initState();
    queueTicker();
  }

  @override
  Widget build(BuildContext context) {
    return widget._builder(context, tickCount);
  }

  void queueTicker() {
    Future.delayed(widget._interval, () {
      if (mounted && widget._active) {
        setState(() {
          tickCount++;
          if (widget._limit != -1 && tickCount > widget._limit) {
            tickCount = 0;
          }
        });
        queueTicker();
      }
    });
  }
}
