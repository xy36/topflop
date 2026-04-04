import 'package:hive_ce/hive_ce.dart';
import 'package:topflop/models/product_item.dart';
import 'package:topflop/models/product_type.dart';

@GenerateAdapters([AdapterSpec<ProductType>(), AdapterSpec<ProductItem>()])
part 'hive_adapters.g.dart';
