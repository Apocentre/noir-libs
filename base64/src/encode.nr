use dep::std::option::Option;
use crate::classic::{get_char_for_index, get_padding_char};

/// Converts eight-bit bytes into six-bit bytes.
/// To do so it takes up to 3 bytes chunks
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

/// Takes a list of up to 4 six-bit bytes and encodes them to base64
fn encode_chunk(chunk: [u8], len: Field) -> [Field] {
  // let len = chunk.len();
  let mut out = [];

  for i in 0..len {
    let chr = get_char_for_index(chunk[i] as Field);
    if Option::is_some(chr) {
      out = out.push_back(Option::unwrap(chr));
    }
  }

  // We need to replicate the code below. that is if the len is < 4 we need to pad right
  // let mut out = [get_padding_char(); 4].as_slice();

  out
}

fn encode(value: [u8]) -> [Field] {
  let value_len = value.len() as u64;
  let chunk_count = value_len / 3;
  let remaining = value_len % 3;
  let mut result = [];

  for i in 0..chunk_count {
    let start_index = 0 + (i * 3);

    let chunk = [
      value[start_index],
      value[start_index + 1],
      value[start_index + 2],
    ];

    let chunk = split(chunk);
    let encoded_chunk = encode_chunk(chunk, 3);

    for i in 0..3 {
      result = result.push_back(encoded_chunk[i]);
    }
  }

  // do the same for the remaining items
  // TODO: abstract this common code 
  let mut remaining_chunk = [];

  for i in 0..remaining {
    remaining_chunk.push_back(value[value_len - i])
  }

  let chunk = split(remaining_chunk);
  let encoded_chunk = encode_chunk(chunk, remaining as Field);

  for i in 0..remaining {
    result = result.push_back(encoded_chunk[i]);
  }

  result
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

// #[test]
// fn test_encode_no_trailing_equal() {
//   // "ABC" in bytes
//   let value = [65, 66, 67];
//   // "QUJD" in bytes
//   let expected = [81, 85, 74, 68];
//   let result = encode(value);

//   for i in 0..4 {
//     assert(result[i] == expected[i]);
//   }
// }
