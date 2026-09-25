class AdFrequencyCounter {
  final int frequency;
  int _count = 0;

  AdFrequencyCounter({required this.frequency});

  /// true si en esta consulta toca mostrar el anuncio.
  bool debeMostrarAnuncio() {
    _count++;
    if (_count >= frequency) {
      _count = 0;
      return true;
    }
    return false;
  }
}
