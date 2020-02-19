import 'dart:math' as math;

double getMean(List<int> gZ) {
  double mean = 0;
  gZ.forEach((g) {
    mean += g;
  });
  return mean / gZ.length;
}

double getVariance(List<int> gZ) {
  double mean = getMean(gZ);
  double variance = 0;
  gZ.forEach((g) {
    variance += math.pow(g - mean, 2);
  });
  return variance / gZ.length;
}

double getPdf(double x, double variance, double mean) {
  double st_ab = math.sqrt(variance);
  double coe = 1 / (st_ab * math.sqrt(2 * math.pi));
  double inner = -1;
  inner /= 2;
  inner *= math.pow((x - mean) / st_ab, 2);
  double exp = math.exp(inner);
  return exp * coe;
}
