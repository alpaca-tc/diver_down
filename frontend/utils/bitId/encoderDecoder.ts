const MAP = [
  "A", // 000000
  "B", // 000001
  "C", // 000010
  "D", // 000011
  "E", // 000100
  "F", // 000101
  "G", // 000110
  "H", // 000111
  "I", // 001000
  "J", // 001001
  "K", // 001010
  "L", // 001011
  "M", // 001100
  "N", // 001101
  "O", // 001110
  "P", // 001111
  "Q", // 010000
  "R", // 010001
  "S", // 010010
  "T", // 010011
  "U", // 010100
  "V", // 010101
  "W", // 010110
  "X", // 010111
  "Y", // 011000
  "Z", // 011001
  "a", // 011010
  "b", // 011011
  "c", // 011100
  "d", // 011101
  "e", // 011110
  "f", // 011111
  "g", // 100000
  "h", // 100001
  "i", // 100010
  "j", // 100011
  "k", // 100100
  "l", // 100101
  "m", // 100110
  "n", // 100111
  "o", // 101000
  "p", // 101001
  "q", // 101010
  "r", // 101011
  "s", // 101100
  "t", // 101101
  "u", // 101110
  "v", // 101111
  "w", // 110000
  "x", // 110001
  "y", // 110010
  "z", // 110011
  "0", // 110100
  "1", // 110101
  "2", // 110110
  "3", // 110111
  "4", // 111000
  "5", // 111001
  "6", // 111010
  "7", // 111011
  "8", // 111100
  "9", // 111101
  "-", // 111110
  "_", // 111111
] as const

type MapKey = typeof MAP[number]

// The id that holds the list of definitions is replaced by a bit (called bitId).
// If this bitId is displayed in the URL as it is, it will become too long, so it is compressed by base64-like simple compression method.
//
// 1. Split the bitId into 6-bit units.
// 2. Convert each 6-bit unit to a character using the MAP table.
// 3. Join the characters to get the compressed string.
//
// NOTE: The result is url friendly.
export const encode = (num: bigint): string => {
  let binary = BigInt(num)

  const parts: string[] = []

  for (;;) {
    const sixBits = Number(binary & 0b111111n)
    const char = MAP[sixBits]
    parts.unshift(char)

    binary >>= 6n

    if (binary === 0n) {
      break
    }
  }

  return parts.join('')
}

export const decode = (encoded: string): bigint => {
  let binary = 0n

  const parts = encoded.split('')

  for (;;) {
    binary <<= 6n
    const char = parts.shift()! as MapKey
    const sixBits = MAP.indexOf(char)
    binary |= BigInt(sixBits)

    if (parts.length === 0) {
      break
    }
  }

  return binary
}
