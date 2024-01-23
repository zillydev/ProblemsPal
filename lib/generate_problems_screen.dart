import 'package:flutter/material.dart';
import 'dart:math';

class GenerateProblemsScreen extends StatelessWidget {
  final Map<String, dynamic> profile;
  const GenerateProblemsScreen({required this.profile, super.key});

  @override
  Widget build(BuildContext context) {
    List<List<String>> problems = generateProblems();

    return Scaffold(
      appBar: AppBar(title: const Text("Problems")),
      body: ListView.builder(
          padding: const EdgeInsets.only(bottom: 100),
          itemCount: problems.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (index == 0) const Divider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                  child: Text(
                    problems[index][0],
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                Column(
                  children: [
                    for (int i = 1; i < problems[index].length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 8.0),
                        child: Text(
                          problems[index][i],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                  ],
                ),
                const Divider()
              ],
            );
          }),
    );
  }

  List<List<String>> generateProblems() {
    List<List<String>> problems = [];
    int index = 0;
    Random random = Random();
    for (int i = 0; i < profile["data"].length; i++) {
      Map<String, dynamic> operation = profile["data"][i];
      if (operation["toggle"]) {
        List<int> body =
            (operation["body"] as List<dynamic>).map((e) => e as int).toList();

        // Addition
        if (i == 0) {
          int numberOfProblems = body[0];
          int numberOfDigits = body[1];
          int min = pow(10, numberOfDigits - 1).toInt();
          int max = (pow(10, numberOfDigits) - 1).toInt();

          problems.add(["Addition:"]);
          for (int j = 0; j < numberOfProblems; j++) {
            int one = generateRandomNumber(random, min, max);
            int two = generateRandomNumber(random, min, max);
            problems[index].add("${j + 1}. $one + $two");
          }
        }

        // Subtraction
        else if (i == 1) {
          int numberOfProblems = body[0];
          int numberOfDigits = body[1];
          int min = pow(10, numberOfDigits - 1).toInt();
          int max = (pow(10, numberOfDigits) - 1).toInt();

          problems.add(["Subtraction:"]);
          for (int j = 0; j < numberOfProblems; j++) {
            int one, two;
            do {
              one = generateRandomNumber(random, min, max);
              two = generateRandomNumber(random, min, one);
            } while (one == two);
            problems[index].add("${j + 1}. $one - $two");
          }
        }

        // Multiplication
        else if (i == 2) {
          int numberOfProblems = body[0];
          int numberOfDigitsMultiplier = body[1];
          int min1 = pow(10, numberOfDigitsMultiplier - 1).toInt();
          int max1 = (pow(10, numberOfDigitsMultiplier) - 1).toInt();

          int numberOfDigitsMultiplicand = body[2];
          int min2 = pow(10, numberOfDigitsMultiplicand - 1).toInt();
          int max2 = (pow(10, numberOfDigitsMultiplicand) - 1).toInt();

          problems.add(["Multiplication:"]);
          for (int j = 0; j < numberOfProblems; j++) {
            int one = generateRandomNumber(random, min1, max1);
            int two = generateRandomNumber(random, min2, max2);
            problems[index].add("${j + 1}. $one x $two");
          }
        }

        // Division
        else if (i == 3) {
          int numberOfProblems = body[0];
          int numberOfDigitsDividend = body[1];
          int min1 = pow(10, numberOfDigitsDividend - 1).toInt();
          int max1 = (pow(10, numberOfDigitsDividend) - 1).toInt();

          int numberOfDigitsDivisor = body[2];
          int min2 = pow(10, numberOfDigitsDivisor - 1).toInt();
          int max2 = (pow(10, numberOfDigitsDivisor) - 1).toInt();

          problems.add(["Division:"]);
          for (int j = 0; j < numberOfProblems; j++) {
            int one, two;
            do {
              one = generateRandomNumber(random, min1, max1);
              if (numberOfDigitsDividend == numberOfDigitsDivisor) {
                two = generateRandomNumber(random, min2, one);
              } else {
                two = generateRandomNumber(random, min2, max2);
              }
            } while (one == two);
            problems[index].add("${j + 1}. $one ÷ $two");
          }
        }
        index++;
      }
    }

    return problems;
  }

  int generateRandomNumber(Random random, int min, int max) {
    if (min == max) return min;

    int range = max - min;
    int num;
    do {
      num = (random.nextDouble() * range).floor() + min;
    } while (num == 0);

    return num;
  }
}
