export const toBlobSuffix = (fullPath: string) => {
  const chunks = fullPath.split(':')

  if (chunks.length > 1 && chunks[chunks.length - 1].match(/^\d+$/)) {
    const line = chunks.pop()
    return `${chunks.join(':')}#L${line}`
  } else {
    return chunks.join(':')
  }
}
