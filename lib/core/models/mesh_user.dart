class MeshUser {
  MeshUser({
    required this.id,
    required this.name,
    required this.bio,
    required this.headline,
    required this.avatarSeed,
    required this.isSelf,
  });

  final String id;
  final String name;
  final String bio;
  final String headline;
  final int avatarSeed;
  final bool isSelf;

  MeshUser copyWith({
    String? name,
    String? bio,
    String? headline,
    int? avatarSeed,
  }) {
    return MeshUser(
      id: id,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      headline: headline ?? this.headline,
      avatarSeed: avatarSeed ?? this.avatarSeed,
      isSelf: isSelf,
    );
  }
}
