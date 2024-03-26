import { Graphviz } from '@hpcc-js/wasm/graphviz'

type Options = {
  width?: string
  height?: string
  fit?: boolean
}

export const renderDot = async (dot: string, options: Options = {}): Promise<string> => {
  const graphviz = await Graphviz.load();
  const svg = graphviz.dot(dot)
  const html: SVGElement = new DOMParser().parseFromString(svg, "text/html").body.querySelector('svg')!

  if (options.width) {
    applyWidth(html, options.width)
  }

  if (options.height) {
    applyHeight(html, options.height)
  }

  if (options.fit) {
    applyFit(html)
  }

  return svg
}

const applyWidth = (svg: SVGElement, width: string) => {
  svg.setAttribute("width", width);
}

const applyHeight = (svg: SVGElement, height: string) => {
  svg.setAttribute("height", height);
}

const applyFit = (svg: SVGElement) => {
  //     element
  //   .attr("height", height);
  // data.attributes.height = height;
}
