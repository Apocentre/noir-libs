use dep::std::option::Option;

global UPPERCASEOFFSET: u8 = 65;
global LOWERCASEOFFSET: u8 = 71;
global DIGITOFFSET: u8 = 4;

pub fn get_char_for_index(index: u8) -> Option<u8> {
  let mut ascii_index: Option<u8> = Option::none();

  // TODO: compare the number of circuits using a poly_root
  if index >=0 & index <= 25 {
    // A-Z
    ascii_index = Option::some(index + UPPERCASEOFFSET);
  } else {
    if index >=26 & index <= 51 {
      // a-z
      ascii_index = Option::some(index + LOWERCASEOFFSET);
    } else {
      if index >=52 & index <= 61 {
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

  // TODO: compare the number of circuits using a poly_root
  if character >=65 & character <= 90 {
    // A-Z
    base64_index = Option::some(character - UPPERCASEOFFSET);
  } else {
    if character >=97 & character <= 122 {
      // a-z
      base64_index = Option::some(character - LOWERCASEOFFSET);
    } else {
      if character >=48 & character <= 57 {
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
