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

fn test_in_range_not_equal() {
  assert(!full_inclusive(9, 10, 50));
  assert(!full_inclusive(51, 10, 50));
  assert(!full_inclusive(1, 10, 50));
  assert(!full_inclusive(1000, 10, 50));
}
