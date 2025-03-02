import 'package:ctue_app/core/services/api_service.dart';
import 'package:ctue_app/core/constants/response.dart';
import 'package:ctue_app/core/params/voca_set_params.dart';
import 'package:ctue_app/core/services/secure_storage_service.dart';
import 'package:ctue_app/features/vocabulary_pack/business/entities/voca_set_entity.dart';
import 'package:ctue_app/features/vocabulary_pack/business/entities/voca_set_response_entity.dart';
import 'package:ctue_app/features/vocabulary_pack/business/entities/voca_statistics_entity.dart';
import 'package:ctue_app/features/vocabulary_pack/business/usecases/download_voca_set%20copy.dart';
import 'package:ctue_app/features/vocabulary_pack/business/usecases/get_usr_voca_sets.dart';
import 'package:ctue_app/features/vocabulary_pack/business/usecases/get_voca_set_detail.dart';
import 'package:ctue_app/features/vocabulary_pack/business/usecases/get_voca_set_statis_usecase.dart';
import 'package:ctue_app/features/vocabulary_pack/business/usecases/get_voca_sets.dart';
import 'package:ctue_app/features/vocabulary_pack/business/usecases/get_voca_sets_admin_usecase.dart';
import 'package:ctue_app/features/vocabulary_pack/business/usecases/rm_voca_set.dart';
import 'package:ctue_app/features/vocabulary_pack/business/usecases/update_voca_set.dart';
import 'package:ctue_app/features/vocabulary_pack/data/datasources/voca_set_local_data_source.dart';
import 'package:data_connection_checker_tv/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/connection/network_info.dart';
import '../../../../../core/errors/failure.dart';
import '../../business/usecases/create_voca_set.dart';

import '../../data/datasources/voca_set_remote_data_source.dart';
import '../../data/repositories/voca_set_repository_impl.dart';

class VocaSetProvider extends ChangeNotifier {
  VocaSetEntity? vocaSetEntity;
  List<VocaSetEntity> userVocaSets = [];
  List<VocaSetEntity> publicVocaSets = [];
  List<VocaSetEntity> listVocaSets = [];
  List<VocaSetEntity> searchResults = [];
  VocaSetStatisticsEntity? vocaSetStatisticsEntity;
  VocaSetStatisticsEntity? homeVocaSetStatisticsEntity;
  VocabularySetResEntity? vocabularySetResEntity;

  Failure? failure;
  String? message = '';
  int? statusCode;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  VocaSetProvider({
    this.vocaSetEntity,
    this.failure,
  });

  Future eitherFailureOrCreVocaSet(String title, int? topicid, int? specId,
      XFile? picture, List<int> words) async {
    _isLoading = true;
    VocaSetRepositoryImpl repository = VocaSetRepositoryImpl(
      remoteDataSource: VocaSetRemoteDataSourceImpl(
        dio: ApiService.dio,
      ),
      localDataSource: VocaSetLocalDataSourceImpl(
        sharedPreferences: await SharedPreferences.getInstance(),
      ),
      networkInfo: NetworkInfoImpl(
        DataConnectionChecker(),
      ),
    );

    final failureOrCreVocaSet =
        await CreVocaSetUsecase(vocaSetRepository: repository).call(
      creVocaSetParams: CreVocaSetParams(
          title: title,
          topicId: topicid,
          specId: specId,
          picture: picture,
          words: words,
          accessToken: await SecureStorageService.secureStorage
                  .read(key: 'accessToken') ??
              ''),
    );

    failureOrCreVocaSet.fold(
      (Failure newFailure) {
        _isLoading = false;
        // vocaSetEntity = null;
        failure = newFailure;
        message = newFailure.errorMessage;
        statusCode = 400;
        notifyListeners();
      },
      (ResponseDataModel<VocaSetEntity> newVocaSet) {
        _isLoading = false;
        // vocaSetEntity = newVocaSet.data;
        message = newVocaSet.message;
        statusCode = newVocaSet.statusCode;
        failure = null;
        notifyListeners();
      },
    );
  }

  Future eitherFailureOrGerUsrVocaSets() async {
    _isLoading = true;
    VocaSetRepositoryImpl repository = VocaSetRepositoryImpl(
      remoteDataSource: VocaSetRemoteDataSourceImpl(
        dio: ApiService.dio,
      ),
      localDataSource: VocaSetLocalDataSourceImpl(
        sharedPreferences: await SharedPreferences.getInstance(),
      ),
      networkInfo: NetworkInfoImpl(
        DataConnectionChecker(),
      ),
    );

    final failureOrGetUsrVocaSets =
        await GetUsrVocaSetUsecase(vocaSetRepository: repository).call(
      getVocaSetParams: GetVocaSetParams(
          accessToken: await SecureStorageService.secureStorage
                  .read(key: 'accessToken') ??
              ''),
    );

    failureOrGetUsrVocaSets.fold(
      (Failure newFailure) {
        _isLoading = false;
        userVocaSets = [];
        failure = newFailure;
        message = newFailure.errorMessage;
        notifyListeners();
      },
      (ResponseDataModel<List<VocaSetEntity>> newVocaSets) {
        _isLoading = false;
        userVocaSets = newVocaSets.data;
        message = newVocaSets.message;
        failure = null;
        notifyListeners();
      },
    );
  }

  Future eitherFailureOrGerVocaSets(
      int? specId, int? topicId, String? key) async {
    _isLoading = true;
    VocaSetRepositoryImpl repository = VocaSetRepositoryImpl(
      remoteDataSource: VocaSetRemoteDataSourceImpl(
        dio: ApiService.dio,
      ),
      localDataSource: VocaSetLocalDataSourceImpl(
        sharedPreferences: await SharedPreferences.getInstance(),
      ),
      networkInfo: NetworkInfoImpl(
        DataConnectionChecker(),
      ),
    );

    final failureOrGetVocaSets =
        await GetVocaSetUsecase(vocaSetRepository: repository).call(
      getVocaSetParams: GetVocaSetParams(
          specId: specId,
          topicId: topicId,
          key: key,
          accessToken: await SecureStorageService.secureStorage
                  .read(key: 'accessToken') ??
              ''),
    );

    failureOrGetVocaSets.fold(
      (Failure newFailure) {
        _isLoading = false;
        publicVocaSets = [];
        failure = newFailure;
        message = newFailure.errorMessage;
        notifyListeners();
      },
      (ResponseDataModel<List<VocaSetEntity>> newVocaSets) {
        _isLoading = false;
        publicVocaSets = newVocaSets.data;
        message = newVocaSets.message;
        failure = null;
        notifyListeners();
      },
    );
  }

  Future eitherFailureOrGetVocaSetsByAdmin(
      int? specId, int? topicId, String? key, int page) async {
    _isLoading = true;
    VocaSetRepositoryImpl repository = VocaSetRepositoryImpl(
      remoteDataSource: VocaSetRemoteDataSourceImpl(
        dio: ApiService.dio,
      ),
      localDataSource: VocaSetLocalDataSourceImpl(
        sharedPreferences: await SharedPreferences.getInstance(),
      ),
      networkInfo: NetworkInfoImpl(
        DataConnectionChecker(),
      ),
    );

    final failureOrGetVocaSets =
        await GetVocaSetByAdminUsecase(vocaSetRepository: repository).call(
      getVocaSetParams: GetVocaSetParams(
          specId: specId,
          topicId: topicId,
          key: key,
          page: page,
          accessToken: await SecureStorageService.secureStorage
                  .read(key: 'accessToken') ??
              ''),
    );

    failureOrGetVocaSets.fold(
      (Failure newFailure) {
        _isLoading = false;
        vocabularySetResEntity = null;
        failure = newFailure;
        message = newFailure.errorMessage;
        notifyListeners();
      },
      (ResponseDataModel<VocabularySetResEntity> newVocaSets) {
        _isLoading = false;
        vocabularySetResEntity = newVocaSets.data;
        message = newVocaSets.message;
        failure = null;
        notifyListeners();
      },
    );
  }

  Future eitherFailureOrGerVocaSetStatistics(int? id) async {
    _isLoading = true;
    VocaSetRepositoryImpl repository = VocaSetRepositoryImpl(
      remoteDataSource: VocaSetRemoteDataSourceImpl(
        dio: ApiService.dio,
      ),
      localDataSource: VocaSetLocalDataSourceImpl(
        sharedPreferences: await SharedPreferences.getInstance(),
      ),
      networkInfo: NetworkInfoImpl(
        DataConnectionChecker(),
      ),
    );

    final failureOrGetVocaSetStatistics =
        await GetVocaSetStatisUsecase(vocaSetRepository: repository).call(
      getVocaSetStatisParams: GetVocaSetStatisParams(
          id: id,
          accessToken: await SecureStorageService.secureStorage
                  .read(key: 'accessToken') ??
              ''),
    );

    failureOrGetVocaSetStatistics.fold(
      (Failure newFailure) {
        _isLoading = false;
        if (id == null) {
          homeVocaSetStatisticsEntity = null;
        } else {
          vocaSetStatisticsEntity = null;
        }
        failure = newFailure;
        message = newFailure.errorMessage;
        notifyListeners();
      },
      (ResponseDataModel<VocaSetStatisticsEntity> newVocaSets) {
        _isLoading = false;
        if (id == null) {
          homeVocaSetStatisticsEntity = newVocaSets.data;
        } else {
          vocaSetStatisticsEntity = newVocaSets.data;
        }
        message = newVocaSets.message;
        failure = null;
        notifyListeners();
      },
    );
  }

  Future eitherFailureOrSearchVocaSets(String? key, int? topicId) async {
    _isLoading = true;
    VocaSetRepositoryImpl repository = VocaSetRepositoryImpl(
      remoteDataSource: VocaSetRemoteDataSourceImpl(
        dio: ApiService.dio,
      ),
      localDataSource: VocaSetLocalDataSourceImpl(
        sharedPreferences: await SharedPreferences.getInstance(),
      ),
      networkInfo: NetworkInfoImpl(
        DataConnectionChecker(),
      ),
    );

    final failureOrSearchVocaSets =
        await GetVocaSetUsecase(vocaSetRepository: repository).call(
      getVocaSetParams: GetVocaSetParams(
          topicId: topicId,
          key: key,
          accessToken: await SecureStorageService.secureStorage
                  .read(key: 'accessToken') ??
              ''),
    );

    failureOrSearchVocaSets.fold(
      (Failure newFailure) {
        _isLoading = false;
        searchResults = [];
        failure = newFailure;
        message = newFailure.errorMessage;
        notifyListeners();
      },
      (ResponseDataModel<List<VocaSetEntity>> newVocaSets) {
        _isLoading = false;
        searchResults = newVocaSets.data;
        message = newVocaSets.message;
        failure = null;
        notifyListeners();
      },
    );
  }

  Future eitherFailureOrGerVocaSetDetail(int id) async {
    _isLoading = true;
    VocaSetRepositoryImpl repository = VocaSetRepositoryImpl(
      remoteDataSource: VocaSetRemoteDataSourceImpl(
        dio: ApiService.dio,
      ),
      localDataSource: VocaSetLocalDataSourceImpl(
        sharedPreferences: await SharedPreferences.getInstance(),
      ),
      networkInfo: NetworkInfoImpl(
        DataConnectionChecker(),
      ),
    );

    final failureOrCreVocaSet =
        await GetVocaSetDetailUsecase(vocaSetRepository: repository).call(
      getVocaSetParams: GetVocaSetParams(
          id: id,
          accessToken: await SecureStorageService.secureStorage
                  .read(key: 'accessToken') ??
              ''),
    );

    failureOrCreVocaSet.fold(
      (Failure newFailure) {
        _isLoading = false;
        vocaSetEntity = null;
        failure = newFailure;
        message = newFailure.errorMessage;
        notifyListeners();
      },
      (ResponseDataModel<VocaSetEntity> newVocaSet) {
        _isLoading = false;
        vocaSetEntity = newVocaSet.data;
        message = newVocaSet.message;
        failure = null;
        notifyListeners();
      },
    );
  }

  Future eitherFailureOrRmVocaSet(int id, bool isDownloaded) async {
    isLoading = true;
    VocaSetRepositoryImpl repository = VocaSetRepositoryImpl(
      remoteDataSource: VocaSetRemoteDataSourceImpl(
        dio: ApiService.dio,
      ),
      localDataSource: VocaSetLocalDataSourceImpl(
        sharedPreferences: await SharedPreferences.getInstance(),
      ),
      networkInfo: NetworkInfoImpl(
        DataConnectionChecker(),
      ),
    );

    final failureOrRmVocaSet =
        await RemoveVocaSetUsecase(vocaSetRepository: repository).call(
      removeVocaSetParams: RemoveVocaSetParams(
          isDownloaded: isDownloaded,
          id: id,
          accessToken: await SecureStorageService.secureStorage
                  .read(key: 'accessToken') ??
              ''),
    );

    failureOrRmVocaSet.fold(
      (Failure newFailure) {
        isLoading = false;
        vocaSetEntity = null;
        failure = newFailure;
        message = newFailure.errorMessage;
        statusCode = 400;
        notifyListeners();
      },
      (ResponseDataModel<VocaSetEntity> newVocaSet) {
        isLoading = false;
        vocaSetEntity = newVocaSet.data;
        message = newVocaSet.message;
        statusCode = newVocaSet.statusCode;

        failure = null;
        notifyListeners();
      },
    );
  }

  Future eitherFailureOrDownVocaSet(int id) async {
    isLoading = true;
    VocaSetRepositoryImpl repository = VocaSetRepositoryImpl(
      remoteDataSource: VocaSetRemoteDataSourceImpl(
        dio: ApiService.dio,
      ),
      localDataSource: VocaSetLocalDataSourceImpl(
        sharedPreferences: await SharedPreferences.getInstance(),
      ),
      networkInfo: NetworkInfoImpl(
        DataConnectionChecker(),
      ),
    );

    final failureOrDownVocaSet =
        await DownloadVocaSetUsecase(vocaSetRepository: repository).call(
      downloadVocaSetParams: DownloadVocaSetParams(
          id: id,
          accessToken: await SecureStorageService.secureStorage
                  .read(key: 'accessToken') ??
              ''),
    );

    failureOrDownVocaSet.fold(
      (Failure newFailure) {
        isLoading = false;
        // vocaSetEntity = null;
        failure = newFailure;
        message = newFailure.errorMessage;
        statusCode = 400;
        notifyListeners();
      },
      (ResponseDataModel<VocaSetEntity> newVocaSet) {
        isLoading = false;
        // vocaSetEntity = newVocaSet.data;
        userVocaSets.add(newVocaSet.data);
        message = newVocaSet.message;
        statusCode = newVocaSet.statusCode;

        failure = null;
        notifyListeners();
      },
    );
  }

  Future eitherFailureOrUpdateVocaSet(
    int id,
    String title,
    int? topicId,
    int? specId,
    String? oldPicture,
    XFile? picture,
    bool? isPublic,
    List<int>? words,
    List<int>? oldWords,
  ) async {
    isLoading = true;
    VocaSetRepositoryImpl repository = VocaSetRepositoryImpl(
      remoteDataSource: VocaSetRemoteDataSourceImpl(
        dio: ApiService.dio,
      ),
      localDataSource: VocaSetLocalDataSourceImpl(
        sharedPreferences: await SharedPreferences.getInstance(),
      ),
      networkInfo: NetworkInfoImpl(
        DataConnectionChecker(),
      ),
    );

    final failureOrCreVocaSet =
        await UpdateVocaSetUsecase(vocaSetRepository: repository).call(
      updateVocaSetParams: UpdateVocaSetParams(
        id: id,
        accessToken:
            await SecureStorageService.secureStorage.read(key: 'accessToken') ??
                '',
        title: title,
        topicId: topicId,
        specId: specId,
        oldPicture: oldPicture,
        picture: picture,
        isPublic: isPublic,
        words: words,
        oldWords: oldWords,
      ),
    );

    failureOrCreVocaSet.fold(
      (Failure newFailure) {
        isLoading = false;
        // vocaSetEntity = null;
        failure = newFailure;
        statusCode = 400;
        message = newFailure.errorMessage;
        notifyListeners();
      },
      (ResponseDataModel<VocaSetEntity> newVocaSet) {
        isLoading = false;
        // vocaSetEntity = newVocaSet.data;
        statusCode = newVocaSet.statusCode;
        message = newVocaSet.message;
        failure = null;
        notifyListeners();
      },
    );
  }

  bool isDownloaded(int id) {
    for (var set in userVocaSets) {
      if (set.id == id) {
        return true;
      }
    }
    return false;
  }
}
