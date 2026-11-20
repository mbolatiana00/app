enum PaymentProvider {
  mvola('MVola', ['034', '038']),
  orangeMoney('Orange Money', ['032', '037']),
  airtelMoney('Airtel Money', ['033']);

  final String label;
  final List<String> prefixes;
  const PaymentProvider(this.label, this.prefixes);
}