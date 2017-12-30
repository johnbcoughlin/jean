class BetaDistribution {
  double alpha;
  double beta;

  BetaDistribution.maxEntropyFor(double p) {
    this.alpha = 2.0;
    this.beta = (1.0 / p) + 1;
  }

  double mode() {
    return (alpha - 1) / (alpha + beta - 2);
  }
}