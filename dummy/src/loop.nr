use dep::std;

fn big_loop() {
  let start = 279;
  let end = 379;
  let big_array = [10; 1000];
  let mut out = [0; 1000];

  for i in 0..1000 {
    let i_int = i as u64;

    if i_int >= start & i_int <=  end {
      out[i_int] = big_array[i];
    }

  }
}

fn reverse_loop(count: u64) {
  let from = 1000;
  let to = 1000 - count;

  std::println(from);
  std::println(to);


  for _ in from..to {
    std::println(">>>>>>>>>>");
  }
}

#[test]
fn test_big_loop() {
  big_loop();
}

#[test]
fn test_reverse_loop() {
  reverse_loop(100);
}
