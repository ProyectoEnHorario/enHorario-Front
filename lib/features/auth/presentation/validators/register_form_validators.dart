class RegisterFormValidators {
  const RegisterFormValidators._();

  static String? validateNombre(String value) {
    if (value.trim().isEmpty) {
      return 'El nombre es obligatorio.';
    }
    return null;
  }

  static String? validateApellido(String value) {
    if (value.trim().isEmpty) {
      return 'El apellido es obligatorio.';
    }
    return null;
  }

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
    if (value.length < 8) {
      return 'Debe tener minimo 8 caracteres.';
    }
    return null;
  }

  static String? validateConfirmPassword({
    required String password,
    required String confirmPassword,
  }) {
    if (confirmPassword.isEmpty) {
      return 'Confirma la contrasena.';
    }
    if (password != confirmPassword) {
      return 'Las contrasenas no coinciden.';
    }
    return null;
  }
}
