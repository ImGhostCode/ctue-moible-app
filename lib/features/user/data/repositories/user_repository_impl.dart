import 'package:ctue_app/core/constants/response.dart';
import 'package:ctue_app/core/params/user_params.dart';
import 'package:ctue_app/features/user/business/entities/user_entity.dart';
import 'package:ctue_app/features/user/data/models/user_model.dart';
import 'package:dartz/dartz.dart';

import '../../../../../core/connection/network_info.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/errors/failure.dart';

import '../../business/repositories/user_repository.dart';
import '../datasources/user_local_data_source.dart';
import '../datasources/user_remote_data_source.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ResponseDataModel<UserModel>>> getUser(
      {required GetUserParams getUserParams}) async {
    if (await networkInfo.isConnected!) {
      try {
        ResponseDataModel<UserModel> remoteUser =
            await remoteDataSource.getUser(getUserParams: getUserParams);

        // localDataSource.cacheUser(UserToCache: remoteUser);

        return Right(remoteUser);
      } on ServerException catch (e) {
        return Left(ServerFailure(
            errorMessage: e.errorMessage, statusCode: e.statusCode));
      }
    } else {
      // try {
      // AccessTokenModel localUser = await localDataSource.getLastUser();
      //   return Right(localUser);
      // } on CacheException {
      return Left(CacheFailure(errorMessage: 'This is a network exception'));
      // }
    }
  }

  @override
  Future<Either<Failure, ResponseDataModel<UserEntity>>> updateUser(
      {required UpdateUserParams updateUserParams}) async {
    if (await networkInfo.isConnected!) {
      try {
        ResponseDataModel<UserModel> remoteUser = await remoteDataSource
            .updateUser(updateUserParams: updateUserParams);

        // localDataSource.cacheUser(UserToCache: remoteUser);

        return Right(remoteUser);
      } on ServerException catch (e) {
        return Left(ServerFailure(
            errorMessage: e.errorMessage, statusCode: e.statusCode));
      }
    } else {
      // try {
      // AccessTokenModel localUser = await localDataSource.getLastUser();
      //   return Right(localUser);
      // } on CacheException {
      return Left(CacheFailure(errorMessage: 'This is a network exception'));
      // }
    }
  }
}
