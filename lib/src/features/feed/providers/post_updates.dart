// Provider to track post updates by URI - when a post gets updated, this gets incremented
import 'package:flutter_riverpod/flutter_riverpod.dart';

final StateProviderFamily<int, String> postUpdateProvider = StateProvider.family<int, String>((ref, postUri) => 0);
