use dep::std::option::Option;
use dep::std;

global EXIST: u8 = 0;
global NULL: u8 = 1;
global DELETED: u8 = 2;

struct Item<T> {
  status: u8,
  value: Option<T>,
}

impl <T> Item<T> {
  fn new(value: T) -> Item<T> {
    Item {
      status: EXIST,
      value: Option::some(value),
    }
  }

  fn default() -> Item<T> {
    Item {
      status: NULL,
      value: Option::none(),
    }
  }

  fn has_value(self) -> bool {
    self.status == EXIST
  }

  fn unwrap(self) -> T {
    self.value.unwrap()
  }

  fn is_null(self) -> bool {
    self.status == NULL
  }

  fn delete(mut self) {
    self.status = DELETED;
    self.value = Option::none();
  } 
}

struct DynamicArray<T, MAX_SIZE> {
  /// The real lenth of the array; i.e. the amount of items it has
  len: u64,
  /// Fixed array of 
  data: [Item<T>; MAX_SIZE],
}

impl <T, MAX_SIZE> DynamicArray<T, MAX_SIZE> {
  pub fn init() -> DynamicArray<T, MAX_SIZE> {
    let mut data = [Item::default(); MAX_SIZE];

    DynamicArray {
      len: 0,
      data,
    }
  }

  pub fn init_with(value: T, len: u64) -> DynamicArray<T, MAX_SIZE> {
    let mut data = [Item::default(); MAX_SIZE];

    for i in 0..len {
      data[i] = Item::new(value);
    }

    DynamicArray {
      len,
      data,
    }
  }

  pub fn from_array<OTHER_MAX_SIZE>(other: [T; OTHER_MAX_SIZE]) -> DynamicArray<T, MAX_SIZE> {
    let mut l:  DynamicArray<T, MAX_SIZE> = DynamicArray::init();

    for i in 0..OTHER_MAX_SIZE {
      l.push(other[i as Field]);
    }

    l
  }

  pub fn len(self) -> u64 {
    self.len
  }

  pub fn get(self, index: Field) -> Item<T> {
    self.data[index]
  }

  pub fn has_value(self, index: Field) -> bool {
    self.data[index].has_value()
  }

  pub fn unwrap(self, index: Field) -> T {
    self.data[index].unwrap()
  }

  pub fn push(&mut self, value: T) {
    self.data[self.len] = Item::new(value);
    self.len += 1;
  }

  pub fn update(&mut self, index: Field, value: T) {
    // you can only update an existing or deleted values
    assert(!self.data[index].is_null());
    self.data[index] = Item::new(value);
  }

  pub fn concat<OTHER_MAX_SIZE>(
    &mut self,
    other: DynamicArray<T, OTHER_MAX_SIZE>,
    other_len: u64,
  ) {
    for i in 0..other_len {
      if other.get(i as Field).has_value() {
        self.push(other.get(i as Field).unwrap());
      }
    }
  }

  pub fn filter(&mut self, self_len: u64, p: fn(T) -> bool) {
    for i in 0..self_len {
      let val = self.data[i];

      if val.has_value() & !p(val.unwrap()) {
        val.delete();
      }
    }
  }
}
