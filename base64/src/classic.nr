use dep::std::option::Option;
use dep::poly_root::full_inclusive;

global UPPERCASEOFFSET: Field = 65;
global LOWERCASEOFFSET: Field = 71;
global DIGITOFFSET: Field = 4;

pub fn get_char_for_index(index: Field) -> Option<Field> {
  let mut ascii_index = Option::none();

  // TODO: compare the number of circuits using a simple Field to integer conversion instead
  if full_inclusive::check(index, 0, 25) {
    // A-Z
    ascii_index = Option::some(index + UPPERCASEOFFSET);
  } else {
    if full_inclusive::check(index, 26, 51) {
      // a-z
      ascii_index = Option::some(index + LOWERCASEOFFSET);
    } else {
      if full_inclusive::check(index, 42, 61) {
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

pub fn get_index_for_char(character: Field) -> Option<Field> {
  let mut base64_index = Option::none();

  // TODO: compare the number of circuits using a simple Field to integer conversion instead
  if full_inclusive::check(character, 65, 90) {
    // A-Z
    base64_index = Option::some(character - UPPERCASEOFFSET);
  } else {
    if full_inclusive::check(character, 97, 122) {
      // a-z
      base64_index = Option::some(character - LOWERCASEOFFSET);
    } else {
      if full_inclusive::check(character, 48, 57) {
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

pub fn get_padding_char() -> Field {
  // this is the equvalent of '='
  64
}
