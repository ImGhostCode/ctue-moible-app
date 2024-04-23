import 'dart:io';

import 'package:ctue_app/core/constants/response.dart';
import 'package:ctue_app/core/params/word_pararms.dart';
import 'package:ctue_app/features/word/data/models/object_model.dart';
import 'package:ctue_app/features/word/data/models/word_model.dart';
import 'package:ctue_app/features/word/data/models/word_response_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../../core/errors/exceptions.dart';

abstract class WordRemoteDataSource {
  Future<ResponseDataModel<WordResModel>> getWords(
      {required GetWordParams getWordParams});
  Future<ResponseDataModel<WordModel>> getWordDetail(
      {required GetWordParams getWordParams});
  Future<ResponseDataModel<WordModel>> createWord(
      {required CreateWordParams createWordParams});
  Future<ResponseDataModel<WordModel>> updateWord(
      {required UpdateWordParams updateWordParams});
  Future<ResponseDataModel<void>> deleteWord(
      {required DeleteWordParams deleteWordParams});
  Future<ResponseDataModel<List<WordModel>>> lookUpDictionary(
      {required LookUpDictionaryParams lookUpDictionaryParams});
  Future<ResponseDataModel<List<ObjectModel>>> lookUpByImage(
      {required LookUpByImageParams lookUpByImageParams});
}

class WordRemoteDataSourceImpl implements WordRemoteDataSource {
  final Dio dio;

  WordRemoteDataSourceImpl({required this.dio});

  @override
  Future<ResponseDataModel<WordResModel>> getWords(
      {required GetWordParams getWordParams}) async {
    try {
      final response = await dio.get('/words',
          queryParameters: {
            'topic': getWordParams.topic!.length > 1
                ? getWordParams.topic
                : [getWordParams.topic],
            "type": getWordParams.type,
            'page': getWordParams.page,
            'level': getWordParams.level,
            'specialization': getWordParams.specialization,
            'sort': getWordParams.sort,
            'key': getWordParams.key,
          },
          options: Options(headers: {
            // "authorization": "Bearer ${getUserParams.accessToken}"
          }));

      return ResponseDataModel<WordResModel>.fromJson(
        json: response.data,
        fromJsonD: (json) => WordResModel.fromJson(json: json),
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.cancel) {
        throw ServerException(
            statusCode: 400, errorMessage: 'Connection Refused');
      } else {
        throw ServerException(
            statusCode: e.response!.statusCode!,
            errorMessage:
                e.response!.data['message'] ?? 'Unknown server error');
      }
    }
  }

  @override
  Future<ResponseDataModel<WordModel>> getWordDetail(
      {required GetWordParams getWordParams}) async {
    try {
      final response = await dio.get('/words/id/${getWordParams.id}',
          queryParameters: {},
          options: Options(headers: {
            // "authorization": "Bearer ${getUserParams.accessToken}"
          }));

      return ResponseDataModel<WordModel>.fromJson(
          json: response.data,
          fromJsonD: (json) => WordModel.fromJson(json: json));
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.cancel) {
        throw ServerException(
            statusCode: 400, errorMessage: 'Connection Refused');
      } else {
        throw ServerException(
            statusCode: e.response!.statusCode!,
            errorMessage:
                e.response!.data['message'] ?? 'Unknown server error');
      }
    }
  }

  @override
  Future<ResponseDataModel<List<WordModel>>> lookUpDictionary(
      {required LookUpDictionaryParams lookUpDictionaryParams}) async {
    try {
      final response = await dio.get(
          '/words/look-up-dictionary?key=${lookUpDictionaryParams.key}',
          queryParameters: {},
          options: Options(headers: {
            // "authorization": "Bearer ${getUserParams.accessToken}"
          }));

      return ResponseDataModel<List<WordModel>>.fromJson(
          json: response.data,
          fromJsonD: (jsonWords) => jsonWords['results']
              ?.map<WordModel>((json) => WordModel.fromJson(json: json))
              .toList());
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.cancel) {
        throw ServerException(
            statusCode: 400, errorMessage: 'Connection Refused');
      } else {
        throw ServerException(
            statusCode: e.response!.statusCode!,
            errorMessage:
                e.response!.data['message'] ?? 'Unknown server error');
      }
    }
  }

  @override
  Future<ResponseDataModel<List<ObjectModel>>> lookUpByImage(
      {required LookUpByImageParams lookUpByImageParams}) async {
    try {
      final String visonKey = dotenv.env['VISON_KEY']!;
      final String baseUrl = dotenv.env['BASE_URL']!;

      final fileBytes = File(lookUpByImageParams.file.path).readAsBytesSync();

      dio.options.baseUrl =
          'https://ctue-mobile-app.cognitiveservices.azure.com';

      final response = await dio.post('/computervision/imageanalysis:analyze',
          data: fileBytes,
          queryParameters: {
            'features': [
              // 'caption',
              // 'dense-aptions',
              'objects',
              // 'people',
              // 'read',
              // 'smart-crops',
              // 'tags'
            ],
            'language': 'en',
            'api-version': '2024-02-01',
            // 'gender-neutral-captions': 'true',
            // 'smartCrops-aspect-ratios': [0.9, 1.33]
          },
          options: Options(headers: {
            "Ocp-Apim-Subscription-Key": visonKey,
            'Content-Type': 'application/octet-stream',
            // 'Content-Type': 'multipart/form-data',
          }));

      dio.options.baseUrl = baseUrl;

      return ResponseDataModel<List<ObjectModel>>.fromJson(
          json: response,
          fromJsonD: (json) {
            final List<dynamic> results = [];
            final values = json['objectsResult']['values'];
            values.forEach((a) {
              results.addAll(a['tags']);
            });
            return results.map((e) => ObjectModel.fromJson(json: e)).toList();
          });
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.cancel) {
        throw ServerException(
            statusCode: 400, errorMessage: 'Connection Refused');
      } else {
        throw ServerException(
            statusCode: e.response!.statusCode!,
            errorMessage:
                e.response!.data['message'] ?? 'Unknown server error');
      }
    }
  }

  @override
  Future<ResponseDataModel<WordModel>> createWord(
      {required CreateWordParams createWordParams}) async {
    try {
      final formData = FormData.fromMap({
        "topicId": createWordParams.topicId.length > 1
            ? createWordParams.topicId
            : [createWordParams.topicId],
        "levelId": createWordParams.levelId,
        "specializationId": createWordParams.specializationId,
        "content": createWordParams.content,
        "meanings": createWordParams.meanings
            .map((meaning) => {
                  'typeId': meaning.typeId,
                  'meaning': meaning.meaning,
                })
            .toList(),
        "note": createWordParams.note,
        "phonetic": createWordParams.phonetic,
        "examples": createWordParams.examples.length > 1
            ? createWordParams.examples
            : [createWordParams.examples],
        "synonyms": createWordParams.synonyms.length > 1
            ? createWordParams.synonyms
            : [createWordParams.synonyms],
        "antonyms": createWordParams.antonyms.length > 1
            ? createWordParams.antonyms
            : [createWordParams.antonyms],
        "pictures": createWordParams.pictures
            .map((e) => MultipartFile.fromFileSync(e.path, filename: e.name))
            .toList(),
      });

      final response = await dio.post('/words',
          data: formData,
          options: Options(headers: {
            "authorization": "Bearer ${createWordParams.accessToken}"
          }));
      return ResponseDataModel<WordModel>.fromJson(
          json: response.data,
          fromJsonD: (json) => WordModel.fromJson(json: json));
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.cancel) {
        throw ServerException(
            statusCode: 400, errorMessage: 'Connection Refused');
      } else {
        throw ServerException(
            statusCode: e.response!.statusCode!,
            errorMessage:
                e.response!.data['message'] ?? 'Unknown server error');
      }
    }
  }

  @override
  Future<ResponseDataModel<WordModel>> updateWord(
      {required UpdateWordParams updateWordParams}) async {
    try {
      final formData = FormData.fromMap({
        "topicId": updateWordParams.topicId.length > 1
            ? updateWordParams.topicId
            : [updateWordParams.topicId],
        "levelId": updateWordParams.levelId,
        "specializationId": updateWordParams.specializationId,
        "content": updateWordParams.content,
        "meanings": updateWordParams.meanings.length > 1
            ? updateWordParams.meanings
                .map((meaning) => {
                      'typeId': meaning.typeId,
                      'meaning': meaning.meaning,
                    })
                .toList()
            : [
                updateWordParams.meanings
                    .map((meaning) => {
                          'typeId': meaning.typeId,
                          'meaning': meaning.meaning,
                        })
                    .toList()
              ],
        "note": updateWordParams.note,
        "phonetic": updateWordParams.phonetic,
        "examples": updateWordParams.examples.length > 1
            ? updateWordParams.examples
            : [updateWordParams.examples],
        "synonyms": updateWordParams.synonyms.length > 1
            ? updateWordParams.synonyms
            : [updateWordParams.synonyms],
        "antonyms": updateWordParams.antonyms.length > 1
            ? updateWordParams.antonyms
            : [updateWordParams.antonyms],
        "oldPictures": updateWordParams.oldPictures.length > 1
            ? updateWordParams.oldPictures
            : [updateWordParams.oldPictures],
        "new_pictures": updateWordParams.pictures
            .map((e) => MultipartFile.fromFileSync(e.path, filename: e.name))
            .toList(),
      });

      final response = await dio.patch('/words/${updateWordParams.wordId}',
          data: formData,
          options: Options(headers: {
            "authorization": "Bearer ${updateWordParams.accessToken}"
          }));
      return ResponseDataModel<WordModel>.fromJson(
          json: response.data,
          fromJsonD: (json) => WordModel.fromJson(json: json));
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.cancel) {
        throw ServerException(
            statusCode: 400, errorMessage: 'Connection Refused');
      } else {
        throw ServerException(
            statusCode: e.response!.statusCode!,
            errorMessage:
                e.response!.data['message'] ?? 'Unknown server error');
      }
    }
  }

  @override
  Future<ResponseDataModel<void>> deleteWord(
      {required DeleteWordParams deleteWordParams}) async {
    try {
      final response = await dio.delete('/words/${deleteWordParams.wordId}',
          options: Options(headers: {
            "authorization": "Bearer ${deleteWordParams.accessToken}"
          }));
      return ResponseDataModel<void>.fromJson(
          json: response.data, fromJsonD: (json) {});
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.cancel) {
        throw ServerException(
            statusCode: 400, errorMessage: 'Connection Refused');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw ServerException(
            statusCode: 500, errorMessage: 'Can\'t connect server');
      } else {
        throw ServerException(
            statusCode: e.response!.statusCode!,
            errorMessage:
                e.response?.data['message'] ?? 'Unknown server error');
      }
    }
  }
}
