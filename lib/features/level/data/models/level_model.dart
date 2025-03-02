import 'package:ctue_app/core/constants/constants.dart';
import 'package:ctue_app/features/level/business/entities/level_entity.dart';

class LevelModel extends LevelEntity {
  LevelModel({super.id, required super.name});

  factory LevelModel.fromJson({required Map<String, dynamic> json}) {
    return LevelModel(id: json[kId], name: json[kName]);
  }

  Map<String, dynamic> toJson() {
    return {kId: id, kName: name};
  }
}
