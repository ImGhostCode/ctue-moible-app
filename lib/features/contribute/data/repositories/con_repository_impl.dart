import 'package:ctue_app/core/constants/response.dart';
import 'package:ctue_app/core/params/contribution_params.dart';
import 'package:ctue_app/features/contribute/business/entities/contri_response_entity.dart';
import 'package:ctue_app/features/contribute/business/entities/contribution_entity.dart';
import 'package:ctue_app/features/contribute/business/repositories/contribution_repositoty.dart';
import 'package:ctue_app/features/contribute/data/models/contri_response_model.dart';
import 'package:ctue_app/features/contribute/data/models/contribution_model.dart';
import 'package:dartz/dartz.dart';

import '../../../../../core/connection/network_info.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/errors/failure.dart';
import '../datasources/contribution_local_data_source.dart';
import '../datasources/contribution_remote_data_source.dart';

class ContributionRepositoryImpl implements ContributionRepository {
  final ContributionRemoteDataSource remoteDataSource;
  final ContributionLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ContributionRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ResponseDataModel<ContributionModel>>>
      createWordContribution(
          {required CreateWordConParams createWordConParams}) async {
    if (await networkInfo.isConnected!) {
      try {
        ResponseDataModel<ContributionModel> remoteContribution =
            await remoteDataSource.createWordContribution(
                createWordConParams: createWordConParams);

        // localDataSource.cacheContribution(ContributionToCache: remoteContribution);

        return Right(remoteContribution);
      } on ServerException catch (e) {
        return Left(ServerFailure(
            errorMessage: e.errorMessage, statusCode: e.statusCode));
      }
    } else {
      return Left(CacheFailure(errorMessage: 'Không thể kết nối với máy chủ'));
    }
  }

  @override
  Future<Either<Failure, ResponseDataModel<ContributionEntity>>>
      createSenContribution(
          {required CreateSenConParams createSenConParams}) async {
    if (await networkInfo.isConnected!) {
      try {
        ResponseDataModel<ContributionModel> remoteContribution =
            await remoteDataSource.createSenContribution(
                createSenConParams: createSenConParams);

        // localDataSource.cacheContribution(ContributionToCache: remoteContribution);

        return Right(remoteContribution);
      } on ServerException catch (e) {
        return Left(ServerFailure(
            errorMessage: e.errorMessage, statusCode: e.statusCode));
      }
    } else {
      return Left(CacheFailure(errorMessage: 'Không thể kết nối với máy chủ'));
    }
  }

  @override
  Future<Either<Failure, ResponseDataModel<ContributionResModel>>>
      getAllContributions({required GetAllConParams getAllConParams}) async {
    if (await networkInfo.isConnected!) {
      try {
        ResponseDataModel<ContributionResModel> remoteContribution =
            await remoteDataSource.getAllCon(getAllConParams: getAllConParams);

        localDataSource.cacheContributionByAdmin(
            contributionResModel: remoteContribution);

        return Right(remoteContribution);
      } on ServerException catch (e) {
        return Left(ServerFailure(
            errorMessage: e.errorMessage, statusCode: e.statusCode));
      }
    } else {
      try {
        ResponseDataModel<ContributionResModel> localContribution =
            await localDataSource.getLastContributionByAdmin();
        return Right(localContribution);
      } on CacheException {
        return Left(
            CacheFailure(errorMessage: 'Không thể kết nối với máy chủ'));
      }
    }
  }

  @override
  Future<Either<Failure, ResponseDataModel<ContributionResEntity>>>
      getAllConByUser(
          {required GetAllConByUserParams getAllConByUserParams}) async {
    if (await networkInfo.isConnected!) {
      try {
        ResponseDataModel<ContributionResModel> remoteContribution =
            await remoteDataSource.getAllConByUser(
                getAllConByUserParams: getAllConByUserParams);

        localDataSource.cacheContributionByUser(
            contributionResModel: remoteContribution);

        return Right(remoteContribution);
      } on ServerException catch (e) {
        return Left(ServerFailure(
            errorMessage: e.errorMessage, statusCode: e.statusCode));
      }
    } else {
      try {
        ResponseDataModel<ContributionResModel> localContribution =
            await localDataSource.getLastContributionByUser();
        return Right(localContribution);
      } on CacheException {
        return Left(
            CacheFailure(errorMessage: 'Không thể kết nối với máy chủ'));
      }
    }
  }

  @override
  Future<Either<Failure, ResponseDataModel<void>>> verifyContribution(
      {required VerifyConParams verifyConParams}) async {
    if (await networkInfo.isConnected!) {
      try {
        ResponseDataModel<void> remoteContribution = await remoteDataSource
            .verifyContribution(verifyConParams: verifyConParams);

        // localDataSource.cacheContribution(ContributionToCache: remoteContribution);

        return Right(remoteContribution);
      } on ServerException catch (e) {
        return Left(ServerFailure(
            errorMessage: e.errorMessage, statusCode: e.statusCode));
      }
    } else {
      return Left(CacheFailure(errorMessage: 'Không thể kết nối với máy chủ'));
    }
  }
}
