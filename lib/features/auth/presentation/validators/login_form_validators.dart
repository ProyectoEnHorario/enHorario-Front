class LoginFormValidators {
  const LoginFormValidators._();

  static String? validateEmail(String value) {
    final email = value.trim();
    if (email.isEmpty) {
      return 'El correo es obligatorio.';
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Ingresa un correo valido.';
    }
    return null;
  }

  static String? validatePassword(String value) {
    if (value.isEmpty) {
      return 'La contrasena es obligatoria.';
    }
    return null;
  }
}
