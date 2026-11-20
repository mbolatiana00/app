final _malagasyPhone = RegExp(r'^(032|033|034|037|038)\d{7}$');

String normalizePhone(String raw) => raw.replaceAll(RegExp(r'[\s.-]'), '');

bool isValidMalagasyPhone(String raw) =>
    _malagasyPhone.hasMatch(normalizePhone(raw));