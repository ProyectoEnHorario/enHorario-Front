class RegisterFormValidators {
  const RegisterFormValidators._();

  static String? validateNombre(String value) {
    final name = value.trim();
    if (name.isEmpty) {
      return 'El nombre es obligatorio.';
    }
    if (name.length < 2) {
      return 'Mínimo 2 caracteres.';
    }
    if (name.length > 80) {
      return 'Máximo 80 caracteres.';
    }
    return null;
  }

  static String? validateApellido(String value) {
    final lastName = value.trim();
    if (lastName.isEmpty) {
      return 'El apellido es obligatorio.';
    }
    if (lastName.length < 2) {
      return 'Mínimo 2 caracteres.';
    }
    if (lastName.length > 80) {
      return 'Máximo 80 caracteres.';
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
      return 'Ingresa un correo válido.';
    }
    return null;
  }

  static String? validatePhone(String value) {
    final phone = value.trim();
    if (phone.isEmpty) return null; // Campo opcional

    if (phone.length < 7) {
      return 'Mínimo 7 caracteres.';
    }
    if (phone.length > 30) {
      return 'Máximo 30 caracteres.';
    }

    final phoneRegex = RegExp(r'^[0-9+\s()-]+$');
    if (!phoneRegex.hasMatch(phone)) {
      return 'Solo números y símbolos + ( ) -';
    }
    return null;
  }

  static String? validatePassword(String value) {
    if (value.isEmpty) {
      return 'La contraseña es obligatoria.';
    }
    if (value.length < 8) {
      return 'Debe tener mínimo 8 caracteres.';
    }
    return null;
  }

  static String? validateConfirmPassword({
    required String password,
    required String confirmPassword,
  }) {
    if (confirmPassword.isEmpty) {
      return 'Confirma la contraseña.';
    }
    if (password != confirmPassword) {
      return 'Las contraseñas no coinciden.';
    }
    return null;
  }

  static String? validateUrl(String value) {
    final url = value.trim();
    if (url.isEmpty) return null;

    if (url.length > 500) {
      return 'Máximo 500 caracteres.';
    }

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return 'Debe iniciar con http:// o https://';
    }
    return null;
  }
}
