/// Polynomial root trick to minimize the number of circuites.
/// A range comparisons cannot work on Field arithmetic i.e. we cannot use gt, lt operators
/// on Field types. Typically, we would have to convert Field into Integer and then do comparisons.
/// However, this adds a significant number of circuits. Here we use the polynomial root trick to 
/// efficiently perform range comparisons.
/// Note! this only make sense for a given ranges. If it is too wide then simply converting into
/// Integer might be more efficient.
/// The following does a `from <= x <= to`
fn full_inclusive(x: Field, from: Field, to: Field) -> bool {
  let mut p = x - from;

  for i in (from + 1)..to + 1 {
    p *= x - i;
  }

  if p == 0 {
    true
  } else {
    false
  }
}

#[test]
fn test_in_range_equal() {
  assert(full_inclusive(10, 10, 50));
  assert(full_inclusive(11, 10, 50));
  assert(full_inclusive(50, 10, 50));
  assert(full_inclusive(49, 10, 50));
  assert(full_inclusive(30, 10, 50));
}
