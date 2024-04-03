const BLANK_TRANSLATE = { x: 0, y: 0 } as const

// Get the translate value of the element
const getTranslate = (el: Element): { x: number; y: number } => {
  const transform = el.getAttribute('transform')
  const translate = /translate\(([^, ]+)(?:,|\s+)([^)]+)\)/.exec(transform ?? '')

  if (translate) {
    return { x: parseFloat(translate[1]), y: parseFloat(translate[2]) }
  } else {
    return BLANK_TRANSLATE
  }
}

// Convert the Point of clientX and clientY to SVG coordinate
export const toSVGPoint = (svg: SVGSVGElement, el: Element, x: number, y: number) => {
  let point = svg.createSVGPoint()
  point.x = x
  point.y = y
  const ctm = svg.getScreenCTM()!.inverse()
  point = point.matrixTransform(ctm)

  let current: Element | null = el
  while (current && svg.contains(current)) {
    const translate = getTranslate(current)
    point.x -= translate.x
    point.y -= translate.y

    current = current.parentElement?.closest('[transform]') ?? null
  }

  return point
}

export const extractSvgSize = (svg: string) => {
  const html: SVGElement = new DOMParser().parseFromString(svg, 'text/html').body.querySelector('svg')!

  if (html === null) {
    return { width: 0, height: 0 }
  }

  const width = parseInt(html.getAttribute('width')!.replace(/pt/, ''), 10)!
  const height = parseInt(html.getAttribute('height')!.replace(/pt/, ''), 10)!

  return { width, height }
}

const SVGGraphTagNames = ['ellipse', 'path', 'polygon', 'polyline', 'rect', 'circle', 'line']
export const isSVGGeometryElement = (el: Element): el is SVGGeometryElement => SVGGraphTagNames.includes(el.tagName)

export const getClosestAndSmallestElement = (elements: Element[], point: DOMPoint): Element | null => {
  let closestElement: Element | null = null
  let minDistance = Infinity
  let minArea = Infinity

  elements.forEach((element) => {
    if (isSVGGeometryElement(element)) {
      const bbox = element.getBBox()
      const centerX = bbox.x + bbox.width / 2
      const centerY = bbox.y + bbox.height / 2
      const distance = Math.sqrt(Math.pow(centerX - point.x, 2) + Math.pow(centerY - point.y, 2))
      const area = bbox.width * bbox.height

      if (element.isPointInFill(point) && (area < minArea || (area === minArea && distance < minDistance))) {
        closestElement = element
        minDistance = distance
        minArea = area
      }
    }
  })

  return closestElement
}
