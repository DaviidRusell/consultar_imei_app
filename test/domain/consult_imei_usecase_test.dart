import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:consultar_imei/domain/entities/imei_entity.dart';
import 'package:consultar_imei/domain/repositories/imei_repository.dart';
import 'package:consultar_imei/domain/usecases/consult_imei_usecase.dart';

import 'consult_imei_usecase_test.mocks.dart';

@GenerateMocks([ImeiRepository])
void main() {
  late MockImeiRepository mockRepository;
  late ConsultImeiUseCase useCase;

  setUp(() {
    mockRepository = MockImeiRepository();
    useCase = ConsultImeiUseCase(mockRepository);
  });

  const tEntity = ImeiEntity(
    imei: '359123456789012',
    estado: 'limpio',
    enBaseNegativa: false,
    causales: [],
    operadores: [],
    reportes: [],
    totalReportes: 0,
    resumen: 'Sin reportes',
  );

  test('debe consultar el repositorio cuando el IMEI es válido', () async {
    when(mockRepository.consultarImei(any)).thenAnswer((_) async => tEntity);

    final result = await useCase('359123456789012');

    expect(result, tEntity);
    verify(mockRepository.consultarImei('359123456789012'));
  });

  test('debe lanzar FormatException con IMEI inválido (muy corto)', () {
    expect(() => useCase('123'), throwsA(isA<FormatException>()));
  });

  test('debe limpiar espacios y guiones antes de validar', () async {
    when(mockRepository.consultarImei(any)).thenAnswer((_) async => tEntity);

    await useCase('359-123-456-789-012'.replaceAll('-', ''));

    verify(mockRepository.consultarImei('359123456789012'));
  });
}
