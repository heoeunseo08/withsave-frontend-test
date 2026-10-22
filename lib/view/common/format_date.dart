// 서버 시간(UTC)을 기기 시간대의 2026.10.23 형태로 보여준다.
String formatDate(String time) {
  final date = DateTime.parse(time).toLocal();
  return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
}
