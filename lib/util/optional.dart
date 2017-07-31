class Optional<T> {
  T value;

  Optional.of(T value) {
    if (value == null) {
      throw new ArgumentError.notNull("value of optional");
    }
    this.value = value;
  }

  Optional.ofNullable(T value) {
    this.value = value;
  }

  Optional.empty() {
    this.value = null;
  }
}