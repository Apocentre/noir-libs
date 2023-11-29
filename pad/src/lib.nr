pub fn pad_left(value: [Field], count: Field, delim: Field) -> [Field] {
  let mut final = value;

  for _ in 0..count {
    final = final.push_front(delim);
  };

  final
}

pub fn pad_right(value: [Field], count: Field, delim: Field) -> [Field] {
  let mut final = value;

  for _ in 0..count {
    final = final.push_back(delim);
  };

  final
}


#[test]
fn test_pad_left() {
  let value = [1, 2, 3, 4, 5].as_slice();
  let expected = [0, 0, 1, 2, 3, 4, 5];
  let result = pad_left(value, 2, 0);

  for i in 0..7 {
    assert(result[i] == expected[i]);
  }
}

#[test]
fn test_pad_right() {
  let value = [1, 2, 3, 4, 5].as_slice();
  let expected = [1, 2, 3, 4, 5, 0, 0];
  let result = pad_right(value, 2, 0);

  for i in 0..7 {
    assert(result[i] == expected[i]);
  }
}
