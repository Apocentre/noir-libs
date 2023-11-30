use dep::std::option::Option;
use dep::std;

global UPPERCASEOFFSET: u8 = 65;
global LOWERCASEOFFSET: u8 = 71;
global DIGITOFFSET: u8 = 4;

pub fn get_char_for_index(index: u8) -> Option<u8> {
  let mut ascii_index = Option::none();

  if index >= 0 & index <= 25 {
    // A-Z
    ascii_index = Option::some(index + UPPERCASEOFFSET);
  } else {
    if index >= 26 & index <= 51 {
      // a-z
      ascii_index = Option::some(index + LOWERCASEOFFSET);
    } else {
      if index >= 52 & index <= 61 {
        // 0-9
        ascii_index = Option::some(index - DIGITOFFSET);
      } else {
        if index == 62 {
          ascii_index = Option::some(43);
        } else {
          if index == 63 {
            ascii_index = Option::some(47);
          }
        }
      }
    }
  };

  ascii_index
}

pub fn get_index_for_char(character: u8) -> Option<u8> {
  let mut base64_index = Option::none();

  if character >= 65 & character <= 90 {
    // A-Z
    base64_index = Option::some(character - UPPERCASEOFFSET);
  } else {
    if character >= 97 & character <= 122 {
      // a-z
      base64_index = Option::some(character - LOWERCASEOFFSET);
    } else {
      if character >= 48 & character <= 57 {
        base64_index = Option::some(character + DIGITOFFSET);
      } else {
        if character == 43 {
          base64_index = Option::some(62);
        } else {
          if character == 47 {
            base64_index = Option::some(63);
          }
        }
      }
    }
  };

  base64_index
}

pub fn get_padding_char() -> u8 {
  // this is the equvalent of '='
  64
}


#[test]
fn test_get_char_for_index() {
  let value: [u8] = [0, 10, 25, 26, 35, 51, 52, 55, 61, 62, 63];
  let expected: [u8] = [65, 75, 90, 97, 106, 122, 48, 51, 57, 43, 47];

  for i in 0..11 {
    let result = Option::unwrap(get_char_for_index(value[i]));
    assert(result == expected[i]);
  }

  let result = get_char_for_index(64);
  assert(Option::is_none(result));
}
