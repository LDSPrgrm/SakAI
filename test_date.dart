void main() {
  try {
    print(DateTime.parse('2026-05-10T13:20:25.753386+08:00'));
  } catch (e) {
    print("Error parsing +08:00: $e");
  }
  try {
    print(DateTime.parse('2026-05-10T13:20:25.753386Z'));
  } catch (e) {
    print("Error parsing Z: $e");
  }
}
