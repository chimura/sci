class AuthorModel {
  final int? id;
  final String? givenName;
  final String familyName;
  final String? orcid;

  const AuthorModel({
    this.id,
    this.givenName,
    required this.familyName,
    this.orcid,
  });

  String get displayName {
    if (givenName != null && givenName!.isNotEmpty) {
      return '$givenName $familyName';
    }
    return familyName;
  }

  String get abbreviatedName {
    if (givenName != null && givenName!.isNotEmpty) {
      return '${givenName![0]}. $familyName';
    }
    return familyName;
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'given_name': givenName,
      'family_name': familyName,
      'orcid': orcid,
    };
  }

  static AuthorModel fromMap(Map<String, dynamic> map) {
    return AuthorModel(
      id: map['id'] as int?,
      givenName: map['given_name'] as String?,
      familyName: map['family_name'] as String,
      orcid: map['orcid'] as String?,
    );
  }
}
