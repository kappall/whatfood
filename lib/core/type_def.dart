import 'package:fpdart/fpdart.dart';
import 'package:whatfood/pages/controller/failure.dart';

typedef FutureEither<T> = Future<Either<Failure, T>>;
typedef FutureVoid = FutureEither<void>;
