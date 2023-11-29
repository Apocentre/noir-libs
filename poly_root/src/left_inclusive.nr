/// The following does a `from <= x < to`
fn left_inclusive(x: Field, from: Field, to: Field) -> bool {
  let mut p = x - from;

  for i in (from + 1)..to {
    p *= x - i;
  }

  if p == 0 {
    true
  } else {
    false
  }
}

#[test]
fn test_in_range() {
  assert(left_inclusive(10, 10, 50));
  assert(left_inclusive(11, 10, 50));
  assert(left_inclusive(49, 10, 50));
  assert(left_inclusive(30, 10, 50));
}

#[test]
fn test_not_in_range() {
  assert(!left_inclusive(9, 10, 50));
  assert(!left_inclusive(50, 10, 50));
  assert(!left_inclusive(100, 10, 50));
}
