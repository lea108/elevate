
double brakingDistance({
  required double currentSpeed,
  required double targetSpeed,
  required double decel,
}) {
  return (currentSpeed * currentSpeed - targetSpeed * targetSpeed) /
      (2 * decel);
}
