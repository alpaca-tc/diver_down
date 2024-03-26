function runLengthEncode(input) {
  let encoded = '';
  let count = 1;
  for (let i = 0; i < input.length; i++) {
    if (input[i] === input[i + 1]) {
      count++;
    } else {
      encoded += count.toString(2) + input[i];
      count = 1;
    }
  }
  return encoded;
}

function runLengthDecode(input) {
  let decoded = '';
  for (let i = 0; i < input.length; i += 2) {
    const count = parseInt(input[i], 2);
    const digit = input[i + 1];
    decoded += digit.repeat(count);
  }
  return decoded;
}

// テスト用の文字列
const inputString = '000111110010';

// ランレングス圧縮
const compressedString = runLengthEncode(inputString);
console.log("圧縮後:", compressedString);

// ランレングス圧縮の解凍
const decompressedString = runLengthDecode(compressedString);
console.log("解凍後:", decompressedString);
