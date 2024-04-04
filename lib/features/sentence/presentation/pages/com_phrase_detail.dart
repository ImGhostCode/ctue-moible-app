import 'package:ctue_app/core/errors/failure.dart';
import 'package:ctue_app/features/sentence/business/entities/sentence_entity.dart';
import 'package:ctue_app/features/sentence/presentation/pages/communication_phrase_page.dart';
import 'package:ctue_app/features/sentence/presentation/providers/sentence_provider.dart';
import 'package:ctue_app/features/sentence/presentation/widgets/listen_sentence_btn.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CommunicationPhraseDetail extends StatelessWidget {
  const CommunicationPhraseDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as ComPhraseArguments;
    Provider.of<SentenceProvider>(context, listen: false)
        .eitherFailureOrSenDetail(args.id);

    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.white,
            scrolledUnderElevation: 0,
            title: Text(
              'Chi tiết câu',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(),
            ),
            centerTitle: true,
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(
                Icons.chevron_left_rounded,
                size: 30,
              ),
            )),
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Consumer<SentenceProvider>(
                builder: (context, sentenceProvider, _) {
              // Access the list of topics from the provider
              SentenceEntity? sentenceDetail = sentenceProvider.sentenceEntity;

              bool isLoading = sentenceProvider.isLoading;

              // Access the failure from the provider
              Failure? failure = sentenceProvider.failure;

              if (failure != null) {
                // Handle failure, for example, show an error message
                return Text(failure.errorMessage);
              } else if (isLoading) {
                // Handle the case where topics are empty
                return const Center(
                    child:
                        CircularProgressIndicator()); // or show an empty state message
              } else if (sentenceDetail == null) {
                // Handle the case where topics are empty
                return const Center(child: Text('Không có dữ liệu'));
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // mainAxisSize: MainAxisSize.max,
                  children: [
                    Center(
                        child: Text(
                      sentenceDetail.content,
                      style: Theme.of(context).textTheme.titleMedium,
                    )),
                    const SizedBox(
                      height: 10,
                    ),
                    Center(
                        child: Text(
                      sentenceDetail.meaning,
                      style: Theme.of(context).textTheme.bodyMedium,
                    )),
                    const SizedBox(
                      height: 10,
                    ),
                    ListenSenButton(text: sentenceDetail.content),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Text(
                          'Loại câu: ',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: Colors.black87),
                        ),
                        Text(
                          sentenceDetail.type!.name,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.normal),
                        )
                      ],
                    ),
                    Text(
                      'Chủ đề:',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: Colors.black87),
                    ),
                    Container(
                      // height: 200,
                      // width: MediaQuery.of(context).size.width - 32,
                      padding: const EdgeInsets.all(8),
                      child: Wrap(
                        spacing:
                            5, // Adjust the spacing between items as needed
                        runSpacing: 10,
                        children: List.generate(
                          sentenceDetail.topics!.length,
                          (index) => Chip(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: Colors.tealAccent.shade200,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            label: Text(sentenceDetail.topics![index].name),
                            backgroundColor: Colors.white,
                            labelStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  fontWeight: FontWeight.normal,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Ghi chú: ',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: Colors.black87),
                        ),
                        Text(
                          sentenceDetail.note ?? '',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.normal),
                        )
                      ],
                    )
                  ],
                );
              }
            })));
  }
}

class Topic {
  final String title;
  bool isSelected;

  Topic({required this.title, required this.isSelected});
}
