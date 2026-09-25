import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'core/theme/app_theme.dart';
import 'data/datasources/imei_remote_datasource.dart';
import 'data/repositories/imei_repository_impl.dart';
import 'domain/usecases/consult_imei_usecase.dart';
import 'presentation/providers/imei_provider.dart';
import 'presentation/screens/home_screen.dart';

void main() {
  runApp(const ConsultarImeiApp());
}

class ConsultarImeiApp extends StatelessWidget {
  const ConsultarImeiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final remoteDataSource = ImeiRemoteDataSourceImpl(client: http.Client());
    final repository = ImeiRepositoryImpl(remoteDataSource: remoteDataSource);
    final useCase = ConsultImeiUseCase(repository);

    return ChangeNotifierProvider(
      create: (_) => ImeiProvider(consultImeiUseCase: useCase),
      child: MaterialApp(
        title: 'Consultar IMEI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: const HomeScreen(),
      ),
    );
  }
}
