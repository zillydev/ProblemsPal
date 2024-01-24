import 'package:flutter/material.dart';

class NumberSelector {
  final FixedExtentScrollController scrollController;
  final BuildContext context;
  final String title;
  final int extent;
  final Function(int) onSubmit;

  NumberSelector(
      {required this.scrollController,
      required this.context,
      required this.title,
      required this.extent,
      required this.onSubmit});

  void dialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text(title),
              titlePadding: const EdgeInsets.fromLTRB(20, 25, 20, 0),
              contentPadding: const EdgeInsets.all(15),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    blendMode: BlendMode.dstOut,
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        colors: [Colors.blue, Colors.transparent, Colors.blue],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ).createShader(bounds);
                    },
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.22,
                      child: RotatedBox(
                        quarterTurns: 0,
                        child: ListWheelScrollView.useDelegate(
                          itemExtent: 35.0,
                          controller: scrollController,
                          childDelegate: ListWheelChildBuilderDelegate(
                              builder: (BuildContext context, int index) {
                                return Text(
                                  '${index + 1}',
                                  style: const TextStyle(fontSize: 24),
                                );
                              },
                              childCount: extent),
                          physics: const FixedExtentScrollPhysics(),
                          diameterRatio: 0.9,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            scrollController.animateToItem(4,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.bounceInOut);
                          },
                          child: const Text("Default")),
                      const Spacer(),
                      ElevatedButton(
                          onPressed: () {
                            onSubmit(scrollController.selectedItem + 1);
                            Navigator.pop(context);
                          },
                          child: const Text("Ok"))
                    ],
                  )
                ],
              ));
        });
  }
}
