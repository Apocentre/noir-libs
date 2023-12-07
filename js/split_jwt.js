const data = require("./data.json");

const main = () => {
  const encoder = new TextEncoder();
  const bytesArray = Array.from(encoder.encode(data.jwt));
  const result = {};
  let i = 0;

  while (bytesArray.length) {
    i++;
    const chunk = bytesArray.splice(0, 100);
    result[`jwt_${i}`] = chunk;
  }

  for (const [key, value] of Object.entries(result)) {
    console.log(`${key}: ${JSON.stringify(value)},`)
  }

  // print an example of empty array as well with length 100
  console.log(JSON.stringify(new Array(100).fill(128)));

}

main();
