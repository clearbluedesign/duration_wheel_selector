library duration_wheel_selector;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';

class DurationWheelSelector extends StatefulWidget {
  final ScrollController scrollController;
  
  final void Function(Duration) onDurationChange;

  // the amount each tick will increment/decrement
  final Duration tickValue;

  // an optional starting value which doesn't immediately snap
  final Duration initialDuration;

  // a max-duration which will limit the number of increments (defaults to infinity)
  final Duration maxDuration;

  // a min-duration which will limit the number of decrements (defaults to 0)
  final Duration minDuration;

  // determines the amount of space between ticks
  final double tickWidth;

  // the widget centered in the tickWidth
  final Widget tick;

  // 12:26 vs 12h 26m
  final bool colonFormat;

  final EdgeInsets padding;

  final TextStyle labelStyle;

  final String timeFormat;

  final bool showLabel;

  final bool showIcon;

  final Icon icon;

  // for fade out
  final List<double> stops;

  DurationWheelSelector({
    Key key,
    @required this.tickValue,
    this.scrollController = ScrollController(),
    this.onDurationChange,
    this.initialDuration,
    this.maxDuration,
    this.minDuration = Duration.zero,
    this.tickWidth = 33.0,
    this.tick,
    this.padding = const EdgeInsets.all(8),
    this.labelStyle =
        const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
    this.timeFormat = 'h:m',
    this.colonFormat = false,
    this.icon = const Icon(Icons.arrow_drop_down),
    this.showIcon = true,
    this.showLabel = true,
    this.stops = const [.03, .5, .97],
  }) : super(key: key) {
    assert(this.tickValue != null);
    assert(this.tickWidth > 0.0);
    assert(this.maxDuration == null ||
        (this.maxDuration.compareTo(this.minDuration) > 0));
    assert(this.maxDuration == null ||
        this.initialDuration == null ||
        (this.maxDuration.compareTo(this.initialDuration) >= 0));
  }

  @override
  _DurationWheelSelectorState createState() => _DurationWheelSelectorState();
}

class _DurationWheelSelectorState extends State<DurationWheelSelector> {
  // total number of ticks in min-max duration
  Duration selectedDuration;
  int itemCount;
  Widget _tick;

  @override
  void initState() {
    super.initState();

    selectedDuration = (widget.initialDuration != null)
        ? Duration(seconds: widget.initialDuration.inSeconds)
        : Duration(seconds: 0);

    if (widget.maxDuration != null) {
      itemCount = widget.maxDuration.inSeconds ~/ widget.tickValue.inSeconds;
    }
    _tick = (widget.tick == null) ? defaultTick() : widget.tick;
  }

  Widget defaultTick() {
    return Container(width: 1, height: 28, color: Colors.black);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          if (widget.showLabel)
            Text(
              formatTime(selectedDuration),
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
            ),
          if (widget.showIcon) widget.icon,
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: <Color>[
                        Colors.transparent,
                        Colors.white,
                        Colors.transparent
                      ],
                      stops: widget.stops)
                  .createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: Container(
              height: 50,
              child: ScrollSnapList(
                listController: widget.scrollController,
                updateOnScroll: true,
                initialIndex:
                    selectedDuration.inSeconds / widget.tickValue.inSeconds,
                onItemFocus: (i) {
                  setState(() {
                    selectedDuration = (i == null)
                        ? selectedDuration
                        : Duration(seconds: i * widget.tickValue.inSeconds);
                  });
                  if (widget.onDurationChange != null)
                    widget.onDurationChange(selectedDuration);
                },
                itemSize: widget.tickWidth,
                itemCount: (itemCount != null) ? itemCount + 1 : null,
                itemBuilder: (context, index) {
                  return Container(
                    width: widget.tickWidth,
                    child: Center(child: _tick),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String formatTime(Duration duration) {
    String formattedTime = "";
    var units = widget.timeFormat.split(":");
    units.forEach((timeUnit) {
      if (timeUnit.startsWith('d')) {
        formattedTime +=
            duration.inDays.toString() + ((widget.colonFormat) ? ":" : "d ");
        duration -= Duration(days: duration.inDays);
      }
      if (timeUnit.startsWith('h')) {
        formattedTime +=
            duration.inHours.toString() + ((widget.colonFormat) ? ":" : "h ");
        duration -= Duration(hours: duration.inHours);
      }
      if (timeUnit.startsWith('m')) {
        formattedTime +=
            duration.inMinutes.toString() + ((widget.colonFormat) ? ":" : "m ");
        duration -= Duration(minutes: duration.inMinutes);
      }
      if (timeUnit.startsWith('s')) {
        formattedTime +=
            duration.inSeconds.toString() + ((widget.colonFormat) ? ":" : "s ");
        duration -= Duration(seconds: duration.inSeconds);
      }
      if (timeUnit.startsWith('ms')) {
        formattedTime += duration.inMilliseconds.toString() +
            ((widget.colonFormat) ? ":" : "ms ");
        duration -= Duration(milliseconds: duration.inMilliseconds);
      }
    });
    if (widget.colonFormat == true) {
      formattedTime.replaceRange(formattedTime.length-1, formattedTime.length-1, "") 
    }
    return formattedTime;
  }
}
