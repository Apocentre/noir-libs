use dep::std::option::Option;
use dep::std;
use dep::collections::dynamic_array::DynamicArray;
use crate::{
  classic::{get_char_for_index, get_padding_char}, constants::MAX_SIZE,
};

/// Converts eight-bit bytes into six-bit bytes.
/// To do so it takes up to 3 bytes chunks
fn split(chunk: DynamicArray<Field, 3>) -> DynamicArray<Field, 4> {
  let len = chunk.len();
  let mut out: DynamicArray<Field, 4> = DynamicArray::init();
  let val_1 = chunk.get(0).unwrap() as u8;

  // In case of a 1-byte input, we return two bytes where the first 6 bits of the input byte are returned as the
  // first output byte, the last two bits of the input byte are returned as the second byte
  if len == 1 {
    out.push((val_1 >> 2) as Field);
    out.push(((val_1 & 3) << 4) as Field);
  } else {
    let val_2 = chunk.get(1).unwrap() as u8;

    if len == 2 {
      out.push((val_1 >> 2) as Field);
      out.push(((val_1 & 3) << 4 | val_2 >> 4) as Field);
      out.push(((val_2 & 15) << 2) as Field);
    } else {
      // In case of a 3 byte input, we follow the same kind of steps to piece different parts of the bytes together to
      // form 4 output bytes each holding 6 bits of information.
      if len == 3 {
        let val_3 = chunk.get(2).unwrap() as u8;

        out.push((val_1 >> 2) as Field);
        out.push(((val_1 & 3) << 4 | val_2 >> 4) as Field);
        out.push(((val_2 & 15) << 2 | val_3 >> 6) as Field);
        out.push((val_3 & 63) as Field);
      } else {
        assert(false, "Chunk must have 3 items at most");
      }
    }
  };

  out
}

/// Takes a list of up to 4 six-bit bytes and encodes them to base64
fn encode_chunk(chunk: DynamicArray<Field, 4>) -> DynamicArray<Field, 4> {
  let mut out = DynamicArray::init_with(get_padding_char() as Field, 4);

  for i in 0..4 {
    if chunk.get(i).has_value() {
      let chr = get_char_for_index(chunk.get(i).unwrap() as u8);

      if Option::is_some(chr) {
        out.update(i, Option::unwrap(chr) as Field);
      }
    }
  }

  out
}

pub fn encode(value: DynamicArray<Field, MAX_SIZE>, value_len: u64) -> DynamicArray<Field, MAX_SIZE> {
  assert((value.len() as u64) == value_len);

  let chunk_count = value_len / 3;
  let remaining = value_len % 3;
  let mut out = DynamicArray::init();

  for i in 0..chunk_count {
    let start_index = (i * 3) as Field;
    let mut chunk = DynamicArray::init();

    chunk.push(value.get(start_index).unwrap());
    chunk.push(value.get(start_index + 1).unwrap());
    chunk.push(value.get(start_index + 2).unwrap());

    let chunk = split(chunk);
    let encoded_chunk = encode_chunk(chunk);
    out.concat(encoded_chunk, 4);
  }

  if remaining != 0 {
    // do the same for the remaining items
    let mut remaining_chunk= DynamicArray::init();

    for i in 0..remaining {
      remaining_chunk.push(value.get((value_len - i - 1) as Field).unwrap());
    }

    let chunk = split(remaining_chunk);
    let encoded_chunk = encode_chunk(chunk);
    out.concat(encoded_chunk, 4);
  }

  out
}

#[test]
fn test_encode_with_trailing_equal() {
  // "ABCD" in bytes
  let value = DynamicArray::from_array([65, 66, 67, 68], 4);
  // "QUJDRA==" in bytes
  let expected: [Field] = [
    81, 85, 74, 68,
    82, 65, get_padding_char() as Field, get_padding_char() as Field,
  ];
  let result = encode(value, 4);

  for i in 0..8 {
    assert(result.get(i).unwrap() == expected[i]);
  }
}

#[test]
fn test_encode_no_trailing_equal() {
  // "ABC" in bytes
  let value =  DynamicArray::from_array([65, 66, 67], 3);
  // "QUJD" in bytes
  let expected = [81, 85, 74, 68];
  let result = encode(value, 3);

  for i in 0..4 {
    assert(result.get(i).unwrap() == expected[i]);
  }
}
