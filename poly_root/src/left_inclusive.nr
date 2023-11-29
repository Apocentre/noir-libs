/// The following does a `from <= x < to`
pub fn check(x: Field, from: Field, to: Field) -> bool {
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
  assert(check(10, 10, 50));
  assert(check(11, 10, 50));
  assert(check(49, 10, 50));
  assert(check(30, 10, 50));
}

#[test]
fn test_not_in_range() {
  assert(!check(9, 10, 50));
  assert(!check(50, 10, 50));
  assert(!check(100, 10, 50));
}
