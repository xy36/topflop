// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class ProductTypeAdapter extends TypeAdapter<ProductType> {
  @override
  final typeId = 0;

  @override
  ProductType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ProductType.food;
      case 1:
        return ProductType.beauty;
      case 2:
        return ProductType.household;
      case 3:
        return ProductType.petFood;
      case 4:
        return ProductType.other;
      default:
        return ProductType.food;
    }
  }

  @override
  void write(BinaryWriter writer, ProductType obj) {
    switch (obj) {
      case ProductType.food:
        writer.writeByte(0);
      case ProductType.beauty:
        writer.writeByte(1);
      case ProductType.household:
        writer.writeByte(2);
      case ProductType.petFood:
        writer.writeByte(3);
      case ProductType.other:
        writer.writeByte(4);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProductItemAdapter extends TypeAdapter<ProductItem> {
  @override
  final typeId = 1;

  @override
  ProductItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductItem(
      id: fields[0] as String,
      barcode: fields[1] as String,
      name: fields[2] as String,
      brand: fields[3] as String?,
      store: fields[4] as String?,
      rating: (fields[5] as num).toInt(),
      notes: fields[6] as String?,
      imageUrl: fields[7] as String?,
      createdAt: fields[8] as DateTime,
      category: fields[9] as String?,
      ingredients: fields[10] as String?,
      localImagePath: fields[11] as String?,
      productType:
          fields[12] == null ? ProductType.food : fields[12] as ProductType,
      price: (fields[13] as num?)?.toDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, ProductItem obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.barcode)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.brand)
      ..writeByte(4)
      ..write(obj.store)
      ..writeByte(5)
      ..write(obj.rating)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.imageUrl)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.category)
      ..writeByte(10)
      ..write(obj.ingredients)
      ..writeByte(11)
      ..write(obj.localImagePath)
      ..writeByte(12)
      ..write(obj.productType)
      ..writeByte(13)
      ..write(obj.price);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
