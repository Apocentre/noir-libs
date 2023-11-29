/// The following does a `from < x <= to`
fn right_inclusive(x: Field, from: Field, to: Field) -> bool {
  let mut p = x - (from + 1);

  for i in (from + 2)..(to + 1) {
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
  assert(right_inclusive(11, 10, 50));
  assert(right_inclusive(50, 10, 50));
  assert(right_inclusive(49, 10, 50));
  assert(right_inclusive(30, 10, 50));
}

#[test]
fn test_not_in_range() {
  assert(!right_inclusive(9, 10, 50));
  assert(!right_inclusive(10, 10, 50));
  assert(!right_inclusive(51, 10, 50));
  assert(!right_inclusive(100, 10, 50));
}
