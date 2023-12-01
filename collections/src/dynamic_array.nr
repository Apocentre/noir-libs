use dep::std::option::Option;
struct DynamicArray<T, MAX_SIZE> {
  /// The real lenth of the array; i.e. the amount of items it has
  len: u16,
  /// Fixed array of 
  data: [Option<T>; MAX_SIZE],
}

impl <T, MAX_SIZE> DynamicArray<T, MAX_SIZE> {
  fn init(value: T, len: u16) -> DynamicArray<T, MAX_SIZE> {
    let mut data = [Option::none(); MAX_SIZE];

    for i in 0..(MAX_SIZE - len) {
      data[i] = Option::some(value);
    }

    DynamicArray {
      len,
      data,
    }
  }

  fn len(self) -> u16 {
    self.len
  }

  fn get(self, index: Field) -> Option<T> {
    self.data[index]
  }

  fn has_value(self, index: Field) -> bool {
    let val = self.data[index];

    Option::is_some(val)
  }

  fn unwrap(self, index: Field) -> T {
    self.data[index].unwrap()
  }
}
