use dep::std::option::Option;
use dep::std;
use dep::collections::dynamic_array::DynamicArray;
use crate::classic::{get_index_for_char, get_padding_char};
use crate::encode::encode;


fn remove_zeros(list: [Field; 4]) -> [Option<Field>; 4] {
  let mut result: [Option<Field>] = [];

  for i in 0..4 {
    let val = list[i];

    if val != 0 {
      result = result.push_back(val);
    }
  }

  result
}

/// Reverse of split we're taking the various bits from two or more bytes and put it back together
/// It takes a slice of bytes and returns another slice of bytes, containing a maximum of three 8-bit numbers.
fn stich(chunk: [Field; 4], len: u64) -> [Field] {
  let mut result: [Field] = [];
  let val_1 = chunk[0] as u8;

  if len == 2 {
    let val_2 = chunk[1] as u8;

    result = [
      ((val_1 & 63) << 2 | val_2 >> 4) as Field,
      ((val_2 & 15) << 4) as Field,
    ];

    result = remove_zeros(result, 2);
  } else {
    let val_2 = chunk[1] as u8;
    let val_3 = chunk[2] as u8;

    if len == 3 {
      result = [
        ((val_1 & 63) << 2 | val_2 >> 4) as Field,
        ((val_2 & 15) << 4 | val_3 >> 2) as Field,
        ((val_3 & 3) << 6) as Field,
      ];
    } else {
      let val_4 = chunk[3] as u8;

      // In case of a 3 byte input, we follow the same kind of steps to piece different parts of the bytes together to
      // form 4 output bytes each holding 6 bits of information.
      if len == 4 {
        result = [
          ((val_1 & 63) << 2 | val_2 >> 4) as Field,
          ((val_2 & 15) << 4 | val_3 >> 2) as Field,
          ((val_3 & 3) << 6 | val_4 & 63) as Field,
        ];
      } else {
        assert(false, "Chunk must have 2 to 4 items at most");
      }

      std::println(result.len());
      result = remove_zeros(result, 3);
    }
  };

  result
}

/// Takes a slice of chars (maximum of 4-bytes). It filters the padding characters and uses the looks up the left-over
/// characters in our alphabet. Returning a slice of bytes as the original data.
fn original(chunk: [Field; 4], len: u64) -> [Field] {
  let mut out = [];

  for i in 0..len {
    let chr = get_index_for_char(chunk[i] as u8);

    if Option::is_some(chr) {
      let ch = Option::unwrap(chr);
      if ch != get_padding_char() {
        out = out.push_back(ch as Field);
      }
    }
  }

  out
}

fn copy_decoded_chunk(mut result: [Field], decoded_chunk: [Field]) -> [Field] {
  let decoded_chunk_len = decoded_chunk.len();

  // the length may vary because we remove the trailing character. Since we can't have a
  // loop with dynamic iteration count we have to do the following
  if decoded_chunk_len == 1 {
    result = result.push_back(decoded_chunk[0] as Field);
  } else {
    if decoded_chunk_len == 2 {
      for i in 0..2 {
        result = result.push_back(decoded_chunk[i] as Field);
      }
    } else {
      if decoded_chunk_len == 3 {
        for i in 0..3 {
          result = result.push_back(decoded_chunk[i] as Field);
        }
      }
    }
  }

  result
}

/// Base64 decode the given value which can gave up to MAX_DECODE_LENGTH items.
/// The actual content to be decoded has length that is defined by `value_len` 
pub fn decode(value: DynamicArray<Field, 2000>) -> [Field] {
  // data MUST be multiple of 4
  let value_len = value.len();
  assert(value_len % 4 == 0);

  let chunk_count = value_len / 4;
  let remaining = value_len % 4;
  let mut result: [Field] = [];

  for i in 0..chunk_count {
    let start_index = (i * 4) as Field;

    let chunk = [
      value.get(start_index),
      value.get(start_index + 1),
      value.get(start_index + 2),
      value.get(start_index + 3),
    ];

    let original_chunk = original(chunk, 4);
    let decoded_chunk = stich(original_chunk, 4);
    result = copy_decoded_chunk(result, decoded_chunk);
  }

  if remaining != 0 {
    // do the same for the remaining items
    let mut remaining_chunk: [Field] = [];

    for i in 0..remaining {
      remaining_chunk = remaining_chunk.push_back(value[value_len - i - 1]);
    }

    let remaining_chunk_len = remaining_chunk.len();
    let mut decoded_chunk = [];

    if remaining_chunk_len == 2 {
      let original_chunk = original(remaining_chunk, 2);
      decoded_chunk = stich(original_chunk);

      result = copy_decoded_chunk(result, decoded_chunk);
    } else {
      if remaining_chunk_len == 3 {
        let original_chunk = original(remaining_chunk, 3);
        decoded_chunk = stich(original_chunk);
        result = copy_decoded_chunk(result, decoded_chunk);
      }
    }
  }

  std::println(result.len());

  result
}

#[test]
fn test_decode_with_trailing_equal() {
  // "ABCD" in bytes
  let value: [Field] = [65, 66, 67, 68];
  // b64 encoded value is "QUJDRA=="
  let encoded = encode(value, 4);
  let result = decode(encoded, 8);

  // for i in 0..4 {
  //   std::println(result[i]);
  //   assert(result[i] == value[i]);
  // }
}
