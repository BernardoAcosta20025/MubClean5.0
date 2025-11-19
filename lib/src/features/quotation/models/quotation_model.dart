// lib/src/features/quotation/models/quotation_model.dart

/// A comprehensive model to hold all data from the quotation flow.
class Quotation {
  // Step 1
  final String selectedService;
  // Step 2
  final String furnitureType;
  final int furnitureQuantity;
  // Step 3
  final String dirtLevel;
  final List<String> stainTypes;
  // Step 4
  final bool petFriendly;
  final bool ecoFriendly;
  final String notes;
  // Step 5
  final String address;
  final String accessInstructions;

  Quotation({
    required this.selectedService,
    required this.furnitureType,
    required this.furnitureQuantity,
    required this.dirtLevel,
    required this.stainTypes,
    required this.petFriendly,
    required this.ecoFriendly,
    required this.notes,
    required this.address,
    required this.accessInstructions,
  });

  // A copyWith method could be added here for state management,
  // but is omitted for now to focus on the data flow fix.
}
