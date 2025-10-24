class RuntimeInformation {
  final String version;
  final String copyright;
  final String builtWith;
  final List<String> configuration;
  final Map<String, Map<String, String>> libraries;
  final List<String>? hardwareAccelerationMethods;

  RuntimeInformation({
    required this.version,
    required this.copyright,
    required this.builtWith,
    required this.configuration,
    required this.libraries,
    this.hardwareAccelerationMethods,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RuntimeInformation) return false;

    return version == other.version &&
        copyright == other.copyright &&
        builtWith == other.builtWith &&
        configuration.toSet().containsAll(other.configuration) &&
        libraries.length == other.libraries.length &&
        libraries.keys.every((key) => libraries[key] == other.libraries[key]) &&
        (hardwareAccelerationMethods?.toSet() ?? {})
            .containsAll(other.hardwareAccelerationMethods ?? []);
  }

  @override
  int get hashCode {
    return Object.hash(
      version,
      copyright,
      builtWith,
      configuration,
      libraries,
      hardwareAccelerationMethods,
    );
  }
}
