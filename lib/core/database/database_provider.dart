import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'daos/paper_dao.dart';

final paperDaoProvider = Provider<PaperDao>((ref) => PaperDao());
