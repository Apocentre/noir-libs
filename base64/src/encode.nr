use dep::std::option::Option;
use dep::std::collections::vec::Vec;
use dep::std;
use crate::classic::{get_char_for_index, get_padding_char};

/// Converts eight-bit bytes into six-bit bytes.
/// To do so it takes up to 3 bytes chunks
fn split(chunk: [Field]) -> [Field] {
  let len = chunk.len();
  let mut result: [Field] = [];
  let val_1 = chunk[0] as u8;

  // In case of a 1-byte input, we return two bytes where the first 6 bits of the input byte are returned as the
  // first output byte, the last two bits of the input byte are returned as the second byte
  if len == 1 {
    result = [
      (val_1 >> 2) as Field,
      ((val_1 & 3) << 4) as Field,
    ];
  } else {
    let val_2 = chunk[1] as u8;

    if len == 2 {
      result = [
        (val_1 >> 2) as Field,
        ((val_1 & 3) << 4 | val_2 >> 4) as Field,
        ((val_2 & 15) << 2) as Field,
      ];
    } else {
      // In case of a 3 byte input, we follow the same kind of steps to piece different parts of the bytes together to
      // form 4 output bytes each holding 6 bits of information.
      if len == 3 {
        let val_3 = chunk[2] as u8;

        result = [
          (val_1 >> 2) as Field,
          ((val_1 & 3) << 4 | val_2 >> 4) as Field,
          ((val_2 & 15) << 2 | val_3 >> 6) as Field,
          (val_3 & 63) as Field,
        ];
      } else {
        assert(false, "Chunk must have 3 items at most");
      }
    }
  };

  result
}

/// Takes a list of up to 4 six-bit bytes and encodes them to base64
fn encode_chunk(chunk: [Field], len: u64) -> [Field] {
  let mut out = [];

  for i in 0..len {
    let chr = get_char_for_index(chunk[i] as u8);

    if Option::is_some(chr) {
      // If we use u8 the runtime panics complaining about incompatible types
      out = out.push_back(Option::unwrap(chr) as Field);
    }
  }

  // TODO: if we use 0..(4-len) which is the correct way, it panics.
  // So we just append 4 padding chars, which doesn't break the logic really
  // since we're consuming the first 4 bytes of the returned encoded chunk.
  for _ in 0..4 {
    out = out.push_back(get_padding_char() as Field);
  }

  out
}

fn encode(value: [Field]) -> [Field] {
  let value_len = value.len() as u64;
  let chunk_count = value_len / 3;
  let remaining = value_len % 3;
  let mut result = [];

  for i in 0..chunk_count {
    let start_index = i * 3;

    let chunk = [
      value[start_index],
      value[start_index + 1],
      value[start_index + 2],
    ];

    let chunk = split(chunk);
    let encoded_chunk = encode_chunk(chunk, 4);

    for i in 0..4 {
      result = result.push_back(encoded_chunk[i] as Field);
    }
  }

  // do the same for the remaining items
  let mut remaining_chunk: [Field] = [];

  for i in 0..remaining {
    remaining_chunk = remaining_chunk.push_back(value[value_len - i - 1]);
  }

  let chunk = split(remaining_chunk);
  let remaining_chunk_len = chunk.len();
  let mut encoded_chunk = [];

  if remaining_chunk_len == 1 {
    encoded_chunk = encode_chunk(chunk, 1);
  } else {
    if remaining_chunk_len == 2 {
      encoded_chunk = encode_chunk(chunk, 2);
      
    }
  };

  for i in 0..4 {
    result = result.push_back(encoded_chunk[i] as Field);
  }

  result
}

#[test]
fn test_encode_with_trailing_equal() {
  // "ABCD" in bytes
  let value: [Field] = [65, 66, 67, 68];
  // "QUJDRA==" in bytes
  let expected: [Field] = [
    81, 85, 74, 68,
    82, 65, get_padding_char() as Field, get_padding_char() as Field,
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
