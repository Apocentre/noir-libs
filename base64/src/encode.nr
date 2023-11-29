use dep::pad;

fn encode(value: [Field]) -> [Field] {
  [1, 2, 3, 4]
}

#[test]
fn test_encode_with_trailing_equal() {
  // "ABCD" in bytes
  let value = [65, 66, 67, 68];
  // "QUJDRA==" in bytes
  let expected = [
    81, 85, 74, 68,
    82, 65, 61, 61,
  ];
  let result = encode(value);

  for i in 0..8 {
    assert(result[i] == expected[i]);
  }
}

#[test]
fn test_encode_no_trailing_equal() {
  // "ABC" in bytes
  let value = [65, 66, 67];
  // "QUJD" in bytes
  let expected = [81, 85, 74, 68];
  let result = encode(value);

  for i in 0..4 {
    assert(result[i] == expected[i]);
  }
}
