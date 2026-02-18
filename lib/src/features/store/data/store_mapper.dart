import '../domain/store.dart';
import 'store_dto.dart';

Store storeFromDto(StoreDto dto) {
  return Store(
    id: dto.id,
    name: dto.name,
    description: dto.description,
    address: dto.address,
    openingHours: dto.openingHours,
    contactInfo: dto.contactInfo,
  );
}
