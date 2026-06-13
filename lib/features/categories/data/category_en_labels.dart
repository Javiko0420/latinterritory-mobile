const Map<String, String> businessLabelsEn = {
  'GASTRONOMIA': 'Food & Dining',
  'TECNOLOGIA': 'Technology',
  'ARTESANIAS': 'Handicrafts',
  'SERVICIOS': 'Services',
  'MODA': 'Fashion',
  'AGRICULTURA': 'Agriculture',
  'TURISMO': 'Tourism',
  'SALUD': 'Health',
  'EDUCACION': 'Education',
  'CONSTRUCCION': 'Construction',
  'TRANSPORTE': 'Transportation',
  'ENTRETENIMIENTO': 'Entertainment',
  'OTROS': 'Other',
};

const Map<String, String> jobLabelsEn = {
  'TECNOLOGIA': 'Technology',
  'HOSTELERIA': 'Hospitality',
  'CONSTRUCCION': 'Construction',
  'VENTAS': 'Sales',
  'MARKETING': 'Marketing',
};

const Map<String, String> eventLabelsEn = {
  'CONCIERTO': 'Concert',
  'TEATRO': 'Theater',
  'COMEDIA': 'Comedy',
  'FIESTA': 'Party',
  'FESTIVAL': 'Festival',
  'DEPORTES': 'Sports',
  'CULTURAL': 'Cultural',
  'NETWORKING': 'Networking',
  'OTRO': 'Other',
};

/// Returns the English label for [value] in the given vertical.
/// Falls back to [fallbackEs] when the value is not yet mapped.
String labelEnFor(String verticalApiKey, String value, String fallbackEs) {
  final map = switch (verticalApiKey) {
    'businesses' => businessLabelsEn,
    'jobs' => jobLabelsEn,
    'events' => eventLabelsEn,
    _ => const <String, String>{},
  };
  return map[value] ?? fallbackEs;
}
