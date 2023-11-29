use dep::std::option::Option;
use dep::poly_root::full_inclusive;

global UPPERCASEOFFSET: Field = 65;
global LOWERCASEOFFSET: Field = 71;
global DIGITOFFSET: Field = 4;

struct Classic;

impl Classic {
  pub fn get_char_for_index(index: Field) -> Option<Field> {
    let mut ascii_index = Option::none();

    // TODO: try polynomial root trics for the following range comparisons to see if we reduce contraint count
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
}
