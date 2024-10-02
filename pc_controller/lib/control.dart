import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:flutter/services.dart';

enum GestureType {
  gestureScale,
  gestureScaleUp,
  gestureScaleDown,
  gestureScroll,
}

class ControlPage extends StatefulWidget {
  const ControlPage({super.key, required this.socket});

  final RawDatagramSocket socket;

  @override
  State<ControlPage> createState() => ControlPageState();
}

class ControlPageState extends State<ControlPage> {
  Offset _delta = Offset.zero;
  GestureType? gestureType;

  void send(String type, String action, String data) {
    Map<String, dynamic> message = {
      'type': type,
      'action': action,
      'data': data,
    };
    var encodeMsg = utf8.encode(json.encode(message));
    try {
      widget.socket.send(encodeMsg, InternetAddress('10.1.1.226'), 10088);
    } catch (e) {
      print('send data failed! $e');
    }
  }

  /// 判断手势类型是缩放还是移动
  /// 缩放类型判断阀值
  double constScaleThreshold = 0.1;
  /// 移动类型判断阀值
  double constPanningThreshold = 20;
  /// 类型判断，移动累计值
  double scaleAccumulatedX = 0;
  double scaleAccumulatedY = 0;
  GestureType checkGestureType(ScaleUpdateDetails touches) {
    if ((1 - touches.scale).abs() >= constScaleThreshold) {
      debugPrint("two touch scale mode:${(1 - touches.scale).abs()}");
      return GestureType.gestureScale;
    }

    scaleAccumulatedX += touches.focalPointDelta.dx;
    scaleAccumulatedY += touches.focalPointDelta.dy;

    if (scaleAccumulatedX.abs() >= constPanningThreshold ||
        scaleAccumulatedY.abs() >= constPanningThreshold) {
      debugPrint(
          "two touch move mode dx:${scaleAccumulatedX.abs()} , dy:${scaleAccumulatedY.abs()}");
      return GestureType.gestureScroll;
    }

    return GestureType.gestureScale;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTapUp: (details) {
                // print('tap up');
                send('mouse', 'left click', '');
              },
              onDoubleTapDown: (details) {
                // print('double tap down');
                send('mouse', 'double click', '');
              },
              onLongPressStart: (details) {
                // print('long press start');
                send('mouse', 'right click', '');
              },
              onPanUpdate: (details) {
                // 一般是10ms
                // if (details.sourceTimeStamp != null) {
                //   print('on pan update, time: ${details.sourceTimeStamp!.inMilliseconds}');
                // }
                // print('send data(dx:${details.delta.dx}, dy:${details.delta.dy}, distance:${details.delta.distance})');
                // 调整鼠标灵敏度，经验参数
                double speed = details.delta.distance;
                if (speed > 10) speed = 10;
                if (speed < 2) speed = 2; 
                Map<String, dynamic> message = {
                  'dx': details.delta.dx * speed,
                  'dy': details.delta.dy * speed,
                };
                send('mouse', 'move', json.encode(message));
                setState(() {
                  _delta = details.delta;
                });
              },
              // onScaleStart: (details) {
              //   if (details.pointerCount >= 2) {
              //     /// 清空手势判断类型参数
              //     _delta = Offset.zero;
              //     scaleAccumulatedX = 0;
              //     scaleAccumulatedY = 0;
              //     gestureType = null;
              //   }
              // },
              // onScaleUpdate: (details) {
              //   if (details.pointerCount >= 2) {
              //     if (gestureType != null) {
              //       gestureType = checkGestureType(details);
              //     }
              //     if (gestureType == GestureType.gestureScale) {
              //       debugPrint("Scale details.scale:${details.scale}");
                    
              //     } else if (gestureType == GestureType.gestureScroll) {
              //       debugPrint("Scroll details.scale:${details.scale}");
              //     }
              //   }
              //   else {
              //   }
              // },
              child: Container(
                // color: Colors.grey,
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(20.0)
                ),
                child: const Icon(Icons.mouse, size: 50, color: Colors.lightBlue,),
              ),
            ),
          ),
          Row(
            children: <Widget>[
              IconButton(
                onPressed: () {
                  send('volume', 'up', '');
                }, 
                icon: const Icon(Icons.volume_up)
              ),
              IconButton(
                onPressed: () {
                  send('volume', 'down', '');
                },
                icon: const Icon(Icons.volume_down)),
              KeyboardListener(
                focusNode: FocusNode(),
                autofocus: true,
                onKeyEvent: (KeyEvent event) {
                  debugPrint("event: ${event.logicalKey.keyLabel}");
                  // return KeyEventResult.ignored;
                },
                child: IconButton(
                    onPressed: (){
                      SystemChannels.textInput.invokeMethod<void>('TextInput.show');
                    },
                    icon: const Icon(Icons.keyboard)),
              )
            ],
          )
        ]
      ),
    );
  }
}