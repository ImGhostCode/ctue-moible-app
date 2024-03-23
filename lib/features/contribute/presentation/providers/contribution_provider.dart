import 'package:ctue_app/core/services/api_service.dart';
import 'package:ctue_app/core/constants/response.dart';
import 'package:ctue_app/core/params/contribution_params.dart';
import 'package:ctue_app/core/services/secure_storage_service.dart';
import 'package:ctue_app/features/contribute/business/entities/contribution_entity.dart';
import 'package:ctue_app/features/contribute/business/usecases/create_sen_contribution.dart';
import 'package:ctue_app/features/contribute/business/usecases/create_word_contribution.dart';
import 'package:ctue_app/features/contribute/business/usecases/get_all_con_usecase.dart';
import 'package:data_connection_checker_tv/data_connection_checker.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/connection/network_info.dart';
import '../../../../../core/errors/failure.dart';
import '../../data/datasources/template_local_data_source.dart';
import '../../data/datasources/contribution_remote_data_source.dart';
import '../../data/repositories/con_repository_impl.dart';

class ContributionProvider extends ChangeNotifier {
  final storage = SecureStorageService.secureStorage;
  ContributionEntity? contributionEntity;
  List<ContributionEntity> listCons = [];
  Failure? failure;
  String? message = '';
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  ContributionProvider({
    this.contributionEntity,
    this.failure,
  });

  Future eitherFailureOrCreWordCon(String type, Content content) async {
    isLoading = true;
    ContributionRepositoryImpl repository = ContributionRepositoryImpl(
      remoteDataSource: ContributionRemoteDataSourceImpl(
        dio: ApiService.dio,
      ),
      localDataSource: TemplateLocalDataSourceImpl(
        sharedPreferences: await SharedPreferences.getInstance(),
      ),
      networkInfo: NetworkInfoImpl(
        DataConnectionChecker(),
      ),
    );

    final failureOrWordContribution =
        await CreateWordConUsecase(contributionRepository: repository).call(
      createWordConParams: CreateWordConParams(
          type: type,
          content: content,
          accessToken: await storage.read(key: 'accessToken') ?? ''),
    );

    failureOrWordContribution.fold(
      (Failure newFailure) {
        isLoading = false;
        contributionEntity = null;
        failure = newFailure;
        message = newFailure.errorMessage;
        notifyListeners();
      },
      (ResponseDataModel<ContributionEntity> newContribution) {
        isLoading = false;
        contributionEntity = newContribution.data;
        message = newContribution.message;
        failure = null;
        notifyListeners();
      },
    );
  }

  Future eitherFailureOrCreSenCon(String type, Content content) async {
    isLoading = true;
    ContributionRepositoryImpl repository = ContributionRepositoryImpl(
      remoteDataSource: ContributionRemoteDataSourceImpl(
        dio: ApiService.dio,
      ),
      localDataSource: TemplateLocalDataSourceImpl(
        sharedPreferences: await SharedPreferences.getInstance(),
      ),
      networkInfo: NetworkInfoImpl(
        DataConnectionChecker(),
      ),
    );

    final failureOrWordContribution =
        await CreateSenConUsecase(contributionRepository: repository).call(
      createSenConParams: CreateSenConParams(
          type: type,
          content: content,
          accessToken: await storage.read(key: 'accessToken') ?? ''),
    );

    failureOrWordContribution.fold(
      (Failure newFailure) {
        isLoading = false;
        contributionEntity = null;
        failure = newFailure;
        message = newFailure.errorMessage;
        notifyListeners();
      },
      (ResponseDataModel<ContributionEntity> newContribution) {
        isLoading = false;
        contributionEntity = newContribution.data;
        message = newContribution.message;
        failure = null;
        notifyListeners();
      },
    );
  }

  Future eitherFailureOrGetAllCons(String type, int status) async {
    _isLoading = true;
    ContributionRepositoryImpl repository = ContributionRepositoryImpl(
      remoteDataSource: ContributionRemoteDataSourceImpl(
        dio: ApiService.dio,
      ),
      localDataSource: TemplateLocalDataSourceImpl(
        sharedPreferences: await SharedPreferences.getInstance(),
      ),
      networkInfo: NetworkInfoImpl(
        DataConnectionChecker(),
      ),
    );

    final failureOrGetAllCons =
        await GetAllConUsecase(contributionRepository: repository).call(
      getAllConParams: GetAllConParams(
          type: type,
          status: status,
          accessToken: await storage.read(key: 'accessToken') ?? ''),
    );

    failureOrGetAllCons.fold(
      (Failure newFailure) {
        _isLoading = false;
        listCons = [];
        failure = newFailure;
        message = newFailure.errorMessage;
        notifyListeners();
      },
      (ResponseDataModel<List<ContributionEntity>> newContributions) {
        _isLoading = false;
        listCons = newContributions.data;
        message = newContributions.message;
        failure = null;
        notifyListeners();
      },
    );
  }
}
