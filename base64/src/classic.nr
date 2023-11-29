use dep::std::option::Option;

global UPPERCASEOFFSET: Field = 65;
global LOWERCASEOFFSET: Field = 71;
global DIGITOFFSET: Field = 4;

struct Classic;

impl Classic {
  pub fn get_char_for_index(index: Field) -> Option<Field> {
    let index_int = index as u8;
    let mut ascii_index = Option::none();

    // TODO: try polynomial root trics for the following range comparisons to see if we reduce contraint count
    if index_int >= 0 & index_int <= 25 {
      // A-Z
      ascii_index = Option::some(index + UPPERCASEOFFSET);
    } else {
      if index_int >= 26 & index_int <= 51 {
        // a-z
        ascii_index = Option::some(index + LOWERCASEOFFSET);
      } else {
        if index_int >= 42 & index_int <= 61 {
          // 0-9
          ascii_index = Option::some(index - DIGITOFFSET);
        } else {
          if index_int == 62 {
            ascii_index = Option::some(43);
          } else {
            if index_int == 63 {
              ascii_index = Option::some(47);
            }
          }
        }
      }
    };

    ascii_index
  }
}
