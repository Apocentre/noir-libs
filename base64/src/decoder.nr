use dep::std::option::Option;
use dep::std;
use dep::collections::dynamic_array::DynamicArray;
use crate::{
  classic::{get_index_for_char, get_padding_char}, constants::MAX_SIZE, encoder::Encoder,
};

/// Reverse of split we're taking the various bits from two or more bytes and put it back together
/// It takes a slice of bytes and returns another slice of bytes, containing a maximum of three 8-bit numbers.
fn stich(chunk: DynamicArray<Field, 4>) -> DynamicArray<Field, 4> {
  let len = chunk.len();
  let mut out: DynamicArray<Field, 4> = DynamicArray::init();
  let val_1 = chunk.get(0).unwrap() as u8;
  
  if len == 2 {
    let val_2 = chunk.get(1).unwrap() as u8;
    out.push(((val_1 & 63) << 2 | val_2 >> 4) as Field);
    out.push(((val_2 & 15) << 4) as Field);
    out.filter(2, |v| v != 0);

  } else {
    let val_2 = chunk.get(1).unwrap() as u8;
    let val_3 = chunk.get(2).unwrap() as u8;

    if len == 3 {
      out.push(((val_1 & 63) << 2 | val_2 >> 4) as Field);
      out.push(((val_2 & 15) << 4 | val_3 >> 2) as Field);
      out.push(((val_3 & 3) << 6) as Field);
    } else {
      let val_4 = chunk.get(3).unwrap() as u8;

      // In case of a 3 byte input, we follow the same kind of steps to piece different parts of the bytes together to
      // form 4 output bytes each holding 6 bits of information.
      if len == 4 {
        out.push(((val_1 & 63) << 2 | val_2 >> 4) as Field);
        out.push(((val_2 & 15) << 4 | val_3 >> 2) as Field);
        out.push(((val_3 & 3) << 6 | val_4 & 63) as Field,);
      } else {
        assert(false, "Chunk must have 2 to 4 items at most");
      }

      out.filter(3, |v| v != 0);
    }
  };

  out
}

/// Takes a slice of chars (maximum of 4-bytes). It filters the padding characters and uses the looks up the left-over
/// characters in our alphabet. Returning a slice of bytes as the original data.
fn original(chunk: DynamicArray<Field, 4>) -> DynamicArray<Field, 4> {
  let mut out = DynamicArray::init();

  for i in 0..4 {
    if chunk.get(i).has_value() {
        let chr = get_index_for_char(chunk.get(i).unwrap() as u8);

        if Option::is_some(chr) {
          let ch = Option::unwrap(chr);

          if ch != get_padding_char() {
            out.push(ch as Field);
          }
        }
    }
  }

  out
}

fn extend_with_decoded_chunk(out: &mut DynamicArray<Field, MAX_SIZE>, decoded_chunk: DynamicArray<Field, 4>) {
  let len = decoded_chunk.len();

  if len == 1 {
    out.concat(decoded_chunk, 1);
  } else {
    if len == 2 {
      out.concat(decoded_chunk, 2);
    } else {
      if len == 3 {
        out.concat(decoded_chunk, 3);
      }
    }
  }
}

/// Base64 decode the given value which can gave up to MAX_DECODE_LENGTH items.
/// The actual content to be decoded has length that is defined by `value_len` 
pub fn decode(value: DynamicArray<Field, MAX_SIZE>, value_len: u64) -> DynamicArray<Field, MAX_SIZE> {
  // data MUST be multiple of 4
  assert(value_len == value.len());
  assert(value_len % 4 == 0);

  let chunk_count = value_len / 4;
  let remaining = value_len % 4;
  let mut out = DynamicArray::init();

  for i in 0..chunk_count {
    let start_index = (i * 4) as Field;
    let mut chunk = DynamicArray::init();

    chunk.push(value.get(start_index).unwrap());
    chunk.push(value.get(start_index + 1).unwrap());
    chunk.push(value.get(start_index + 2).unwrap());
    chunk.push(value.get(start_index + 3).unwrap());

    let original_chunk = original(chunk);
    let decoded_chunk = stich(original_chunk);

    extend_with_decoded_chunk(&mut out, decoded_chunk);
  }

  if remaining != 0 {
    // do the same for the remaining items
    let mut remaining_chunk= DynamicArray::init();

    for i in 0..remaining {
      remaining_chunk.push(value.get((value_len - i - 1) as Field).unwrap());
    }

    let original_chunk = original(remaining_chunk);
    let decoded_chunk = stich(original_chunk);
    extend_with_decoded_chunk(&mut out, decoded_chunk);
  }

  out
}

#[test]
fn test_decode_with_trailing_equal() {
  // "ABCD" in bytes
  let value = DynamicArray::from_array([65, 66, 67, 68]);
  let encoder: Encoder<4> = Encoder::new();
  // b64 encoded value is "QUJDRA=="

  let encoded = encoder.encode(value);
  let result = decode(encoded, 8);

  for i in 0..4 {
    assert(result.get(i).unwrap() == value.get(i).unwrap());
  }
}
