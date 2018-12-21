class Utils {
  static int sortRetainingSelected<T extends Comparable>(
      T first, T second, T selected) {
    if (first == second) {
      return 0;
    } else if (first == selected) {
      return -1;
    } else if (second == selected) {
      return 1;
    } else {
      return first.compareTo(second);
    }
  }
}
