use dep::pad;

fn split(chunk: [u8]) -> [u8] {
  let len = chunk.len();
  let mut result = [];

  // In case of a 1-byte input, we return two bytes where the first 6 bits of the input byte are returned as the
  // first output byte, the last two bits of the input byte are returned as the second byte
  if len == 1 {
    result = [
      chunk[0] >> 2,
      (chunk[0] & 3) << 4
    ];
  } else {
    if len == 2 {
      result = [
        chunk[0]  >> 2,
        (chunk[0] & 3) << 4 | chunk[1] >> 4,
        (chunk[1] & 15) << 2,
      ];
    } else {
      // In case of a 3 byte input, we follow the same kind of steps to piece different parts of the bytes together to
      // form 4 output bytes each holding 6 bits of information.
      if len == 3 {
        result = [
          chunk[0] >> 2,
          (chunk[0] & 3) << 4 | chunk[1] >> 4,
          (chunk[1] & 15) << 2 | chunk[2] >> 6,
          chunk[2] & 63,
        ];
      } else {
        assert(false, "Chunk must have 3 items at most");
      }
    }
  };

  result
}

fn encode(value: [u8]) -> [u8] {
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
