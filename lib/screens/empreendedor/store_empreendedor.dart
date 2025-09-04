class EmpreendedorStore {
  EmpreendedorStore._privateConstructor();
  static final EmpreendedorStore instance = EmpreendedorStore._privateConstructor();

  List<Map<String, dynamic>> projetos = [];
  int pontosGlobais = 0;

  void enviarProjeto(Map<String, dynamic> projeto) {
    projetos.add(projeto);
    // 50 pontos ao enviar
    pontosGlobais += 50;
  }

  void aprovarProjeto(int index) {
    if (index < 0 || index >= projetos.length) return;
    projetos[index]['status'] = 'Aprovado';
    // 150 pontos ao aprovar
    pontosGlobais += 150;
  }

  List<Map<String, dynamic>> getProjetosAprovados() {
    return projetos.where((p) => p['status'] == 'Aprovado').toList();
  }
}
