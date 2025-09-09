class CurrentUser {
  // Singleton
  CurrentUser._privateConstructor();
  static final CurrentUser instance = CurrentUser._privateConstructor();

  int? id;
  String? email;
  String? role;
  int points = 0;

  // Inicializa os dados do usuário após login
  void setUser({required int userId, required String userEmail, required String userRole, int userPoints = 0}) {
    id = userId;
    email = userEmail;
    role = userRole;
    points = userPoints;
  }

  void addPoints(int pts) {
    points += pts;
  }

  void reset() {
    id = null;
    email = null;
    role = null;
    points = 0;
  }
}
