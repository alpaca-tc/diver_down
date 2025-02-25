import { Graphviz } from '@hpcc-js/wasm-graphviz'

export const renderDot = async (dot: string): Promise<string> => {
  const graphviz = await Graphviz.load()
  return graphviz.dot(dot)
}
