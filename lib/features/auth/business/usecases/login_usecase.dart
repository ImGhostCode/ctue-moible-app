import 'package:ctue_app/core/constants/response.dart';
import 'package:ctue_app/core/params/auth_params.dart';
import 'package:ctue_app/features/auth/business/entities/login_entity.dart';
import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failure.dart';
// import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUsecase {
  final AuthRepository authRepository;

  LoginUsecase({required this.authRepository});

  Future<Either<Failure, ResponseDataModel<LoginEntity>>> call({
    required LoginParams loginParams,
  }) async {
    return await authRepository.login(loginParams: loginParams);
  }
}
