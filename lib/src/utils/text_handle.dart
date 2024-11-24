/// Truncates the given [text] to be at most [maxLength] characters long and
/// appends an ellipsis to the end if it was truncated.
///
/// This is useful for displaying text that is too long to fit in the
/// alloted space.
String truncateWithEllipsis(int maxLength, String text) {
  if (text.length <= maxLength) return text;
  return '${text.substring(0, maxLength)}...';
}
