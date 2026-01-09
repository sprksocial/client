// Provider to track post updates by URI
// When a post gets updated, this gets incremented
import 'package:flutter_riverpod/legacy.dart';

final StateProviderFamily<int, String> postUpdateProvider =
    StateProvider.family<int, String>((ref, postUri) => 0);
