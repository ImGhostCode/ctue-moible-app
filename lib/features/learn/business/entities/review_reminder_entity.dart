import 'package:ctue_app/features/learn/business/entities/user_learned_word_entity.dart';
import 'package:ctue_app/features/user/business/entities/user_entity.dart';
import 'package:ctue_app/features/vocabulary_pack/business/entities/voca_set_entity.dart';
// import 'package:ctue_app/features/word/business/entities/word_entity.dart';

class ReviewReminderEntity {
  final int id;
  final int vocabularySetId;
  final int userId;
  final bool isDone;
  // List<WordEntity> words = [];
  List<UserLearnedWordEntity> learnedWords = [];
  final DateTime reviewAt;
  final DateTime createdAt;
  final VocaSetEntity? vocaSetEntity;
  final UserEntity? userEntity;

  ReviewReminderEntity(
      {required this.id,
      required this.vocabularySetId,
      required this.userId,
      required this.isDone,
      required this.learnedWords,
      required this.reviewAt,
      required this.createdAt,
      this.userEntity,
      this.vocaSetEntity});
}
