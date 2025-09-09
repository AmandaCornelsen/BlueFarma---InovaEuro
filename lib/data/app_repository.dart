import 'package:inovaeuro/database_help.dart';

class AppRepository {
  AppRepository._();
  static final instance = AppRepository._();

  final _db = DatabaseHelper.instance;

  Map<String, dynamic>? currentUser;

  // ===== LOGIN =====
  Future<bool> login({required String email, required String password}) async {
    final user = await _db.getUser(email, password);
    if (user != null) {
      currentUser = user;
      return true;
    }
    return false;
  }

  void logout() {
    currentUser = null;
  }

  int? get currentUserId => currentUser?['id'];
  String? get currentUserRole => currentUser?['role'];

  int get currentUserPoints => currentUser?['points'] ?? 0;

  // ===== IDEIAS =====
  Future<int> criarIdeia({
    required String titulo,
    required String descricao,
    required String categoria,
    required int duracaoDias,
  }) async {
    if (currentUserId == null) throw Exception("Usuário não logado");
    final id = await _db.insertIdea(
      authorId: currentUserId!,
      titulo: titulo,
      descricao: descricao,
      categoria: categoria,
      duracaoDias: duracaoDias,
    );
    await _db.addUserPoints(currentUserId!, 50); // bônus envio
    // Atualiza pontos locais
    currentUser!['points'] = currentUserPoints + 50;
    return id;
  }

  Future<void> aprovarIdeia({
    required int ideiaId,
    required int empreendedorId, required int executivoId,
  }) async {
    await _db.updateIdeaStatus(ideiaId, 'approved');
    await _db.addUserPoints(empreendedorId, 150); // bônus aprovação
  }

  Future<void> rejeitarIdeia(int ideiaId) async {
    await _db.updateIdeaStatus(ideiaId, 'pending'); // ou 'rejected' se preferir
  }

  Future<void> setProgressoIdeia(int ideiaId, double progress) async {
    await _db.updateIdeaProgress(ideiaId, progress);
    if (progress >= 1.0) {
      await _db.updateIdeaStatus(ideiaId, 'completed');
    } else if (progress > 0.0) {
      await _db.updateIdeaStatus(ideiaId, 'in_progress');
    }
  }

  Future<Map<String, int>> countsDashboard() => _db.countIdeasByStatus();
  Future<List<Map<String, dynamic>>> ultimasIdeias(int limit) => _db.getRecentIdeas(limit);
  Future<List<Map<String, dynamic>>> ideiasPendentes() => _db.getIdeasByStatus('pending');
  Future<List<Map<String, dynamic>>> ideiasAprovadas() => _db.getIdeasByStatus('approved');
  Future<List<Map<String, dynamic>>> ideiasEmAndamento() => _db.getIdeasByStatus('in_progress');
  Future<List<Map<String, dynamic>>> ideiasFinalizadas() => _db.getIdeasByStatus('completed');

  // ===== USERS =====
  Future<List<Map<String, dynamic>>> executivos() => _db.getExecutives();

  // ===== CHAT =====
  Future<int> abrirOuCriarConversa(int executiveId) async {
    if (currentUserId == null) throw Exception("Usuário não logado");
    return _db.createOrGetConversation(executiveId, currentUserId!);
  }

  Future<List<Map<String, dynamic>>> conversasDoUsuario() async {
    if (currentUserId == null || currentUserRole == null) return [];
    return _db.listConversationsForUser(currentUserId!, currentUserRole!);
  }

  Future<int> enviarMensagem({
    required int conversationId,
    required String body,
  }) async {
    if (currentUserId == null || currentUserRole == null) throw Exception("Usuário não logado");
    return _db.sendMessage(
      conversationId: conversationId,
      senderId: currentUserId!,
      senderRole: currentUserRole!,
      body: body,
    );
  }

  Future<List<Map<String, dynamic>>> mensagensDaConversa(int conversationId) =>
      _db.getMessages(conversationId);
}
