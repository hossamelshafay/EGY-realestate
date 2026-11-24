/// Stable category codes used by the authenticated catalog.
enum PropertyCategory {
  residentialSale('buy'),
  residentialRent('rent'),
  commercialSale('commercial_buy'),
  commercialRent('commercial_rent');

  const PropertyCategory(this.code);
  final String code;

  static PropertyCategory? fromCode(String? code) {
    for (final category in values) {
      if (category.code == code) return category;
    }
    return null;
  }
}
