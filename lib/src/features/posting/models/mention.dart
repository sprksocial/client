class Mention {
  const Mention({
    required this.handle,
    required this.did,
    required this.byteStart,
    required this.byteEnd,
  });

  final String handle;
  final String did;
  final int byteStart;
  final int byteEnd;

  Mention copyWith({
    String? handle,
    String? did,
    int? byteStart,
    int? byteEnd,
  }) {
    return Mention(
      handle: handle ?? this.handle,
      did: did ?? this.did,
      byteStart: byteStart ?? this.byteStart,
      byteEnd: byteEnd ?? this.byteEnd,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Mention &&
        other.handle == handle &&
        other.did == did &&
        other.byteStart == byteStart &&
        other.byteEnd == byteEnd;
  }

  @override
  int get hashCode => Object.hash(handle, did, byteStart, byteEnd);

  @override
  String toString() =>
      'Mention(handle: $handle, did: $did, byteStart: $byteStart, byteEnd: $byteEnd)';
}
