import 'package:ctue_app/core/errors/failure.dart';
import 'package:ctue_app/features/learn/presentation/providers/learn_provider.dart';
import 'package:ctue_app/features/notification/presentation/widgets/notification_icon.dart';
import 'package:ctue_app/features/word/presentation/widgets/look_up_dic_bar.dart';
import 'package:ctue_app/features/learn/presentation/widgets/action_box.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  // bool isDark = false;
  final List<Recommend> _listRecommends = [
    Recommend(path: '/contribution', title: 'Đóng góp từ vựng'),
    Recommend(path: '/setting', title: 'Cài đặt giọng đọc'),
  ];

  @override
  Widget build(BuildContext context) {
    final List<LearningSource> learningSources = [
      LearningSource(
        icon: Icons.abc,
        title: 'Bảng phiên âm IPA',
        bgColor: Colors.green,
        onTap: () {
          Navigator.pushNamed(context, '/api');
        },
      ),
      LearningSource(
        icon: Icons.record_voice_over_outlined,
        title: 'Mẫu câu giao tiếp',
        bgColor: Colors.blueAccent,
        onTap: () {
          Navigator.pushNamed(context, '/communication-phrases');
        },
      ),
      LearningSource(
        icon: Icons.menu_book,
        title: 'Từ điển',
        bgColor: Colors.yellow,
        onTap: () {
          Navigator.pushNamed(context, '/dictionary');
        },
      ),
      LearningSource(
        icon: Icons.article,
        title: 'Động từ bất quy tắc',
        bgColor: Colors.orange,
        onTap: () {
          Navigator.pushNamed(context, '/irregular-verb');
        },
      ),
      // LearningSource(
      //   icon: Icons.sports_esports,
      //   title: 'Game',
      //   bgColor: Colors.teal.shade400,
      //   onTap: () {
      //     Navigator.pushNamed(context, '/games');
      //   },
      // ),
    ];

    if (Provider.of<LearnProvider>(context, listen: false).upcomingReminder ==
            null ||
        Provider.of<LearnProvider>(context, listen: false).currReminder ==
            null) {
      Provider.of<LearnProvider>(context, listen: false)
          .eitherFailureOrGetUpcomingReminder();
    }

    return Scaffold(
        appBar: AppBar(
          // centerTitle: true,
          title: Image.asset(
              'assets/images/ctue-high-resolution-logo-transparent2.png',
              width: 150),

          actions: const [NotificationIcon()],
        ),
        body: SingleChildScrollView(
            child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(color: Colors.grey.shade100),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Từ điển',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      const LookUpDicBar()
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),

                // Text(
                //   'Đề xuất cho bạn',
                //   style: Theme.of(context).textTheme.titleLarge,
                // ),
                // SizedBox(
                //   height: 90.0, // Set a fixed height for the ListView
                //   child: ListView.builder(
                //     scrollDirection: Axis.horizontal,
                //     itemCount: 1, // Number of items in your list
                //     itemBuilder: (BuildContext context, int index) {
                //       return Padding(
                //         padding: const EdgeInsets.all(8.0),
                //         child: Column(
                //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //           children: [
                //             ClipRRect(
                //               borderRadius: BorderRadius.circular(10),
                //               child: Image.asset(
                //                 'assets/images/chatbot.png',
                //                 height: 52,
                //                 width: 52,
                //               ),
                //             ),
                //             Text(
                //               'CTUE AI',
                //               style: Theme.of(context).textTheme.bodyMedium,
                //             )
                //           ],
                //         ),
                //       );
                //     },
                //   ),
                // ),

                Consumer<LearnProvider>(
                  builder: (context, provider, child) {
                    bool isLoading = provider.isLoading;

                    Failure? failure = provider.failure;

                    if (failure != null) {
                      // Handle failure, for example, show an error message
                      return Text(failure.errorMessage);
                    } else if (isLoading) {
                      // Handle the case where topics are empty
                      return const Center(
                          child:
                              CircularProgressIndicator()); // or show an empty state message
                    } else if (provider.currReminder != null) {
                      return Container(
                        decoration: const BoxDecoration(color: Colors.white),
                        padding: const EdgeInsets.all(16.0),
                        child: ActionBox(
                          vocabularySetId:
                              provider.currReminder!.vocabularySetId,
                          words: provider.currReminder!.words,
                          reviewAt: provider.currReminder!.reviewAt,
                        ),
                      );
                    } else if (provider.upcomingReminder != null) {
                      return Container(
                        decoration: const BoxDecoration(color: Colors.white),
                        padding: const EdgeInsets.all(16.0),
                        child: ActionBox(
                          vocabularySetId:
                              provider.upcomingReminder!.vocabularySetId,
                          words: provider.upcomingReminder!.words,
                          reviewAt: provider.upcomingReminder!.reviewAt,
                        ),
                      );
                    } else {
                      return Container(
                        decoration: const BoxDecoration(color: Colors.white),
                        padding: const EdgeInsets.all(16.0),
                        child: const ActionBox(
                          vocabularySetId: -1,
                          words: [],
                        ),
                      );
                    }
                  },
                ),

                /*
                 return const Center(
                          child: Text(
                              'Không có dữ liệu'));
                */

                const SizedBox(
                  height: 10,
                ),

                Container(
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nguồn học',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        child: GridView.builder(
                          itemCount: learningSources.length,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 18,
                            mainAxisSpacing: 16,
                          ),
                          primary: false,
                          // padding: const EdgeInsets.all(8),
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: learningSources[index].onTap,
                              child: Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 5),
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: learningSources[index].bgColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      learningSources[index].icon,
                                      size: 26,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    learningSources[index].title,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đề xuất cho bạn',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                leading: Icon(
                                  Icons.recommend,
                                  size: 40,
                                  color: Colors.yellow.shade700,
                                ),
                                title: Text(_listRecommends[index].title),
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, _listRecommends[index].path);
                                },
                                trailing: const Icon(
                                  Icons.chevron_right_rounded,
                                  size: 28,
                                ),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return const SizedBox(
                                height: 2,
                              );
                            },
                            itemCount: _listRecommends.length)
                      ]),
                )
              ]),
        )));
  }
}

class Recommend {
  final String title;
  final String path;

  Recommend({required this.path, required this.title});
}

class LearningSource {
  final IconData icon;
  final String title;
  final Color bgColor;
  final VoidCallback onTap;

  LearningSource(
      {required this.icon,
      required this.title,
      required this.bgColor,
      required this.onTap});
}
