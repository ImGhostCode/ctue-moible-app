import 'package:ctue_app/core/constants/response.dart';
import 'package:ctue_app/core/params/sentence_params.dart';
import 'package:ctue_app/features/sentence/business/repositories/sentece_repository.dart';
import 'package:ctue_app/features/sentence/data/datasources/sentence_local_data_source.dart';
import 'package:ctue_app/features/sentence/data/datasources/sentence_remote_data_source.dart';
import 'package:ctue_app/features/sentence/data/models/sentence_model.dart';
import 'package:ctue_app/features/sentence/data/models/word_response_model.dart';

import 'package:dartz/dartz.dart';

import '../../../../../core/connection/network_info.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/errors/failure.dart';

class SentenceRepositoryImpl implements SentenceRepository {
  final SentenceRemoteDataSource remoteDataSource;
  final SentenceLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  SentenceRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ResponseDataModel<SentenceResModel>>> getSentences(
      {required GetSentenceParams getSentenceParams}) async {
    if (await networkInfo.isConnected!) {
      try {
        ResponseDataModel<SentenceResModel> remoteSentence =
            await remoteDataSource.getSentences(
                getSentenceParams: getSentenceParams);

        localDataSource.cacheSentence(sentenceResModel: remoteSentence);

        return Right(remoteSentence);
      } on ServerException catch (e) {
        return Left(ServerFailure(
            errorMessage: e.errorMessage, statusCode: e.statusCode));
      }
    } else {
      try {
        ResponseDataModel<SentenceResModel> localSentence =
            await localDataSource.getLastSentence();
        return Right(localSentence);
      } on CacheException {
        return Left(
            CacheFailure(errorMessage: 'Không thể kết nối với máy chủ'));
      }
    }
  }

  @override
  Future<Either<Failure, ResponseDataModel<SentenceModel>>> getSentenceDetail(
      {required GetSentenceParams getSentenceParams}) async {
    if (await networkInfo.isConnected!) {
      try {
        ResponseDataModel<SentenceModel> remoteSentence = await remoteDataSource
            .getSentenceDetail(getSentenceParams: getSentenceParams);

        localDataSource.cacheSentenceDetail(sentenceModel: remoteSentence);

        return Right(remoteSentence);
      } on ServerException catch (e) {
        return Left(ServerFailure(
            errorMessage: e.errorMessage, statusCode: e.statusCode));
      }
    } else {
      try {
        ResponseDataModel<SentenceModel> localSentenceDetail =
            await localDataSource.getLastSentenceDetail();
        if (localSentenceDetail.data.id != getSentenceParams.id) {
          return Left(
              CacheFailure(errorMessage: 'Không thể kết nối với máy chủ'));
        }
        return Right(localSentenceDetail);
      } on CacheException {
        return Left(
            CacheFailure(errorMessage: 'Không thể kết nối với máy chủ'));
      }
    }
  }

  @override
  Future<Either<Failure, ResponseDataModel<SentenceModel>>> createSentence(
      {required CreateSentenceParams createSentenceParams}) async {
    if (await networkInfo.isConnected!) {
      try {
        ResponseDataModel<SentenceModel> remoteSentence = await remoteDataSource
            .createSentence(createSentenceParams: createSentenceParams);

        // localDataSource.cacheAuth(AuthToCache: remoteSentence);

        return Right(remoteSentence);
      } on ServerException catch (e) {
        return Left(ServerFailure(
            errorMessage: e.errorMessage, statusCode: e.statusCode));
      }
    } else {
      return Left(CacheFailure(errorMessage: 'Không thể kết nối với máy chủ'));
    }
  }

  @override
  Future<Either<Failure, ResponseDataModel<SentenceModel>>> updateSentence(
      {required EditSentenceParams editSentenceParams}) async {
    if (await networkInfo.isConnected!) {
      try {
        ResponseDataModel<SentenceModel> remoteSentence = await remoteDataSource
            .editSentence(editSentenceParams: editSentenceParams);

        // localDataSource.cacheAuth(AuthToCache: remoteSentence);

        return Right(remoteSentence);
      } on ServerException catch (e) {
        return Left(ServerFailure(
            errorMessage: e.errorMessage, statusCode: e.statusCode));
      }
    } else {
      return Left(CacheFailure(errorMessage: 'Không thể kết nối với máy chủ'));
    }
  }

  @override
  Future<Either<Failure, ResponseDataModel<void>>> deleteSentence(
      {required DeleteSentenceParams deleteSentenceParams}) async {
    if (await networkInfo.isConnected!) {
      try {
        ResponseDataModel<void> remoteSentence = await remoteDataSource
            .deleteSentence(deleteSentenceParams: deleteSentenceParams);

        // localDataSource.cacheAuth(AuthToCache: remoteSentence);

        return Right(remoteSentence);
      } on ServerException catch (e) {
        return Left(ServerFailure(
            errorMessage: e.errorMessage, statusCode: e.statusCode));
      }
    } else {
      return Left(CacheFailure(errorMessage: 'Không thể kết nối với máy chủ'));
    }
  }
}
