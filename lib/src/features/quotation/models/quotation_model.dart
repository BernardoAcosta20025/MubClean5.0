class Quotation {
  final String selectedService;
  // Ahora guardamos una lista de configuraciones complejas
  final List<Map<String, dynamic>> furnitureItems;
  // Ej: [{'type': 'Sofá', 'size': 'Grande', 'material': 'Tela', 'dirt': 'Alto', 'price': 500}]

  final String address;
  final String receiverName; // Persona que recibe
  final double distanceFee; // Costo por distancia
  final double itemsTotal; // Costo de los muebles

  Quotation({
    required this.selectedService,
    required this.furnitureItems,
    required this.address,
    required this.receiverName,
    required this.distanceFee,
    required this.itemsTotal,
  });

  double get totalAmount => itemsTotal + distanceFee;

  factory Quotation.empty() {
    return Quotation(
      selectedService: '',
      furnitureItems: [],
      address: '',
      receiverName: '',
      distanceFee: 0.0,
      itemsTotal: 0.0,
    );
  }
}
