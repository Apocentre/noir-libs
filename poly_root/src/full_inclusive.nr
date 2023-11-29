/// The following does a `from <= x <= to`
pub fn check(x: Field, from: Field, to: Field) -> bool {
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
  assert(check(10, 10, 50));
  assert(check(11, 10, 50));
  assert(check(50, 10, 50));
  assert(check(49, 10, 50));
  assert(check(30, 10, 50));
}

fn test_in_range_not_equal() {
  assert(!check(9, 10, 50));
  assert(!check(51, 10, 50));
  assert(!check(1, 10, 50));
  assert(!check(1000, 10, 50));
}
