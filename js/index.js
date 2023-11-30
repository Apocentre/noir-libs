const assert = require("assert");
const data = require("./data.json");

const toBits = (value) =>  {
  let output = "";
  for (let i = 0; i < value.length; i++) {
    output += value[i].charCodeAt(0)
    .toString(2)
    .padStart(8, '0') + " ";
  }

  return output
}

const toByteArray = (str) => {
  let utf8Encode = new TextEncoder();
  return utf8Encode.encode(str)
}

const fromByteArray = (byteArray) => {
  let utf8Decode = new TextDecoder();
  return utf8Decode.decode(byteArray)
}

const main = () => {
  const userId = toByteArray(data.userId);
  const jwt = toByteArray(data.jwt);

  // generate the text at all possible three-byte offsets, and remove the characters that might be influenced by the context
  const offset_0 = btoa(fromByteArray(userId));
  // add one character infront. @ is 64 in decimal
  let offset_1 = btoa(fromByteArray(new Uint8Array([64, ...userId])));
  // add two character infront
  let offset_2 = btoa(fromByteArray(new Uint8Array([64, 64, ...userId])));

  // Adding three will have a strint that contains the offset_0 as a substring; So we don't need to take this into
  // account. We really have only three possbile version of the b64 encoded userId
  const offset_3 = btoa(fromByteArray(new Uint8Array([64, 64, 64, ...userId])));
  
  console.log({offset_0, offset_1, offset_2, offset_3})

  // remove 4 bytes from start and end of offset_1 and offset_2
  offset_1 = offset_1.slice(4).slice(0, -4);
  offset_2 = offset_2.slice(4).slice(0, -4);

  console.log({offset_0, offset_1, offset_2});

  offset_1 = toByteArray(offset_1);
  const userIdLen = offset_1.length;

  // we know that the offset_1 version is a the version that is part of the encoded jwt.
  const startIndex = 431;

  // Assert that that offset_1 is indeed part of the encoded jwt
  for (let i = startIndex, j = 0; i < startIndex + userIdLen; i++, j++) {
    assert(jwt[i] === offset_1[j]);
  }
}


main();
