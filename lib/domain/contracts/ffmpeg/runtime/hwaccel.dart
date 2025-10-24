/// Hardware acceleration options for video processing
enum HwAccel {
  none('none', 'None', true);

  const HwAccel(this.value, this.displayName, this.implemented);

  final String value;
  final String displayName;
  final bool implemented;
}
