import 'package:ctue_app/core/constants/response.dart';
import 'package:ctue_app/core/errors/failure.dart';
import 'package:ctue_app/core/params/user_params.dart';
import 'package:ctue_app/features/auth/business/entities/account_entiry.dart';
import 'package:ctue_app/features/user/business/repositories/user_repository.dart';

import 'package:dartz/dartz.dart';

class GetAccountDetailUsecase {
  final UserRepository userRepository;

  GetAccountDetailUsecase({required this.userRepository});

  Future<Either<Failure, ResponseDataModel<AccountEntity>>> call({
    required GetAccountParams getAccountParams,
  }) async {
    return await userRepository.getAccountDetailByAdmin(
        getAccountParams: getAccountParams);
  }
}
