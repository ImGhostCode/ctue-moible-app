import 'package:ctue_app/core/constants/constants.dart';
import 'package:ctue_app/features/learn/business/entities/user_learned_word_entity.dart';
import 'package:ctue_app/features/skeleton/providers/selected_page_provider.dart';
import 'package:ctue_app/features/word/business/entities/word_entity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class ActionBox extends StatefulWidget {
  final bool isLoadingPage;
  final List<WordEntity> words;
  final int vocabularySetId;
  final int? reviewReminderId;
  final DateTime? reviewAt;
  final List<UserLearnedWordEntity> userLearnedWords;

  const ActionBox(
      {super.key,
      this.words = const [],
      this.userLearnedWords = const [],
      required this.vocabularySetId,
      this.reviewReminderId,
      this.reviewAt,
      this.isLoadingPage = false});

  @override
  State<ActionBox> createState() => _ActionBoxState();
}

class _ActionBoxState extends State<ActionBox> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateRemainingTime(); // Start updating immediately
  }

  @override
  void dispose() {
    _timer?.cancel(); // Clean up the timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color:
              widget.isLoadingPage ? isLoadingColor : Colors.lightBlue.shade100,
          boxShadow: const [BoxShadow(color: Colors.grey, blurRadius: 3)]),
      child: Row(
        children: [
          Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.error_outline_sharp,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(
                        width: 3,
                      ),
                      Expanded(
                          flex: 1, // Adjust the flex value as needed
                          child: _getTitleAction()),
                    ],
                  ),
                  (widget.reviewAt != null &&
                          DateTime.now().isAfter(widget.reviewAt!))
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 25,
                            ),
                            Text(
                              '${widget.userLearnedWords.length.toString()} từ',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      color: Colors.redAccent.shade200,
                                      fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(
                    height: 5,
                  ),
                  SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ButtonStyle(
                            shape: MaterialStatePropertyAll(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8))),
                            backgroundColor: MaterialStatePropertyAll(
                                widget.isLoadingPage
                                    ? isLoadingColor
                                    : Colors.blue.shade500)),
                        onPressed: widget.words.isEmpty
                            ? () {
                                Provider.of<SelectedPageProvider>(context,
                                        listen: false)
                                    .changePage(1);
                              }
                            : widget.reviewAt != null &&
                                    DateTime.now().isAfter(widget.reviewAt!)
                                ? () {
                                    Navigator.of(context).pushNamed('/learn',
                                        arguments: LearnringArguments(
                                            reviewReminderId:
                                                widget.reviewReminderId,
                                            words: widget.userLearnedWords
                                                .map((e) => e.word!)
                                                .toList(),
                                            memoryLevels: widget
                                                .userLearnedWords
                                                .map((e) => e.memoryLevel)
                                                .toList(),
                                            vocabularySetId:
                                                widget.vocabularySetId));
                                  }
                                : () async {
                                    if (Provider.of<SelectedPageProvider>(
                                                context,
                                                listen: false)
                                            .selectedPage !=
                                        1) {
                                      Provider.of<SelectedPageProvider>(context,
                                              listen: false)
                                          .changePage(1);
                                    } else {
                                      List<WordEntity> unLearnedWords = widget
                                          .words
                                          .where((element) => !widget
                                              .userLearnedWords
                                              .map((e) => e.wordId)
                                              .contains(element.id))
                                          .toList();
                                      // final dynamic result =
                                      // await

                                      if (unLearnedWords.isNotEmpty) {
                                        Navigator.of(context)
                                            .pushNamed('/select-word',
                                                arguments: SelectWordArguments(
                                                  vocabularySetId:
                                                      widget.vocabularySetId,
                                                  words: unLearnedWords,
                                                  callback: (selectedWords) {},
                                                ));
                                      }
                                    }
                                  },
                        child: Text(
                          // ''
                          getTtileActionButton(),
                        ),
                      ))
                ],
              )),
          const SizedBox(
            width: 10,
          ),
          Expanded(
              flex: 2,
              child: SizedBox(
                  height: 100,
                  width: 100,
                  child: Image.asset(
                    'assets/images/note.png',
                    fit: BoxFit.cover,
                  )))
        ],
      ),
    );
  }

  Widget _getTitleAction() {
    if (widget.vocabularySetId == -1) {
      return Text(
        'Bắt đầu học để ghi nhớ từ trong kho từ vựng của bạn nhé',
        textAlign: TextAlign.left,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.bold,
            ),
      );
    } else if (widget.reviewAt != null &&
        DateTime.now().isAfter(widget.reviewAt!)) {
      return Text(
        'Đã đến lúc ôn tập',
        textAlign: TextAlign.left,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.bold,
            ),
      );
    } else if (widget.reviewAt != null) {
      return RichText(
          text: TextSpan(
        text: 'Bạn có ',
        style: Theme.of(context).textTheme.bodyLarge,
        children: [
          TextSpan(
            text: '${widget.userLearnedWords.length} từ vựng ',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Colors.blue.shade800,
                ),
          ),
          TextSpan(
            text: 'cần ôn tập',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(),
          ),
          TextSpan(
            text: ' ${getRemainingTime()}',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Colors.blue.shade800,
                ),
          )
        ],
      ));
    } else {
      return Text('Bắt đầu học để ghi nhớ từ trong kho từ vựng của bạn nhé',
          textAlign: TextAlign.left,
          style: Theme.of(context).textTheme.bodyLarge);
    }

    //  'Bạn có ${widget.words.length} từ vựng cần ôn tập sau ${getRemainingTime()}'
    // : 'Bắt đầu học để ghi nhớ từ trong kho từ vựng của bạn nhé';
  }

  void _updateRemainingTime() {
    if (widget.reviewAt != null) {
      Duration remainingTime = widget.reviewAt!.difference(DateTime.now());
      if (remainingTime <= Duration.zero) {
        _timer?.cancel();
        setState(() {}); // Update UI if review time is past
      } else {
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {}); // Update the UI every second
        });
      }
    }
  }

  String getTtileActionButton() {
    // if (widget.reviewAt != null) {
    //   print(DateTime.now().isBefore(widget.reviewAt!));
    // }

    if (widget.words.isEmpty) {
      return 'Học từ vựng';
    } else if (widget.reviewAt != null &&
        DateTime.now().isAfter(widget.reviewAt!)) {
      return 'Ôn tập ngay';
    } else if (widget.reviewAt != null) {
      // Duration remainingTime = DateTime.parse(widget.reviewAt!
      //         .toString()
      //         .substring(0, widget.reviewAt.toString().length - 1))
      //     .difference(DateTime.now());

      // if (remainingTime <= Duration.zero) {
      //   return 'Ôn tập ngay'; // It's due
      // }

      // // Format remaining time
      // String twoDigits(int n) => n.toString().padLeft(2, '0');
      // String twoDigitMinutes = twoDigits(remainingTime.inMinutes.remainder(60));
      // String twoDigitSeconds = twoDigits(remainingTime.inSeconds.remainder(60));
      // return "${remainingTime.inHours}h:${twoDigitMinutes}m:${twoDigitSeconds}s";
      return 'Học từ mới';
    } else {
      return 'Học từ vựng'; // If reviewAt is null
    }
  }

  String getRemainingTime() {
    Duration remainingTime = DateTime.parse(widget.reviewAt!
            .toString()
            .substring(0, widget.reviewAt.toString().length - 1))
        .difference(DateTime.now());

    if (remainingTime <= Duration.zero) {
      return ''; // It's due
    }

    // Format remaining time
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(remainingTime.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(remainingTime.inSeconds.remainder(60));
    return "sau ${remainingTime.inHours}h:${twoDigitMinutes}m:${twoDigitSeconds}s";
  }
}

class LearnringArguments {
  List<WordEntity> words = [];
  List<int> memoryLevels = [];
  int vocabularySetId;
  int? reviewReminderId;
  LearnringArguments(
      {required this.words,
      required this.memoryLevels,
      required this.vocabularySetId,
      this.reviewReminderId});
}

class SelectWordArguments {
  List<WordEntity> words = [];
  final Function(List<WordEntity>) callback;
  int vocabularySetId;
  SelectWordArguments(
      {required this.words,
      required this.callback,
      required this.vocabularySetId});
}
