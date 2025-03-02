import 'package:ctue_app/core/constants/constants.dart';
import 'package:ctue_app/features/topic/data/models/topic_model.dart';
import 'package:ctue_app/features/user/business/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel(
      {required super.id,
      required super.name,
      super.avt,
      required super.isDeleted,
      required super.createdAt,
      required super.updatedAt,
      super.interestTopics,
      super.accountType});

  factory UserModel.fromJson({required Map<String, dynamic> json}) {
    return UserModel(
        id: json['User'] != null ? json['User']['id'] : json['id'],
        name: json['User'] != null ? json['User']['name'] : json['name'],
        avt: json['User'] != null ? json['User']['avt'] : json['avt'],
        accountType: json['accountType'],
        isDeleted: json['User'] != null
            ? json['User']['isDeleted']
            : json['isDeleted'],
        createdAt: json['User'] != null
            ? DateTime.parse(json['User']['createdAt'])
            : DateTime.parse(json['createdAt']),
        updatedAt: json['User'] != null
            ? DateTime.parse(json['User']['updatedAt'])
            : DateTime.parse(json['updatedAt']),
        interestTopics: json['User'] != null
            ? json['User'][kInterestTopics]?.map<TopicModel>((e) {
                return TopicModel.fromJson(json: e);
              }).toList()
            : json[kInterestTopics]?.map<TopicModel>((e) {
                return TopicModel.fromJson(json: e);
              }).toList());
  }

  Map<String, dynamic> toJson() {
    return {
      kId: id,
      kName: name,
      kAvt: avt,
      kIsDeleted: isDeleted,
      kCreatedAt: createdAt.toString(),
      kAccountType: accountType,
      kUpdatedAt: updatedAt.toString(),
      kInterestTopics:
          (interestTopics as List<dynamic>?)?.map((e) => e.toJson()).toList()
    };
  }
}
