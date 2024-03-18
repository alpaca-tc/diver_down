import * as d3 from "d3";
import "hpcc-js";
import "d3-graphviz";

import path from "utils/path"
import { delegate } from "utils/delegate";
import { request } from "utils/request";
import { debounse } from "utils/debounse";

const renderSources = (sources) => {
  const ul = document.querySelector("[data-target='definition-sources']")
  ul.innerHTML = ''

  sources.forEach((source) => {
    const li = document.createElement("li")
    const anchor = document.createElement("a")

    anchor.innerText = source.source_name
    anchor.setAttribute("href", path.sources.show(source.source_name))
    anchor.setAttribute("_target", 'blank')

    li.appendChild(anchor)
    ul.appendChild(li)
  })
}

const renderDot = async (response) => {
  document.querySelector("[data-target='definition-title']").innerText = response.title
  document.querySelector("[data-target='definition-id']").innerText = response.bit_id

  history.pushState(null, null, `#definition-${response.bit_id}`)

  const graphEl = document.querySelector("[data-target='definition-graph']")
  const graphviz = d3
    .select("[data-target='definition-graph']")
    .graphviz()

  graphviz
    .options({
      fit: true,
      width: graphEl.clientWidth,
      height: graphEl.clientHeight,
      zoom: true,
    })
    .renderDot(response.dot)

  try {
    // Error occurs when the graph is not zoomed yet
    graphviz.resetZoom()
  } catch(e) {}
}

const drawDefinition = async (bitId) => {
  const response = await request(
    path.definitions.show(bitId),
    {
      method: "GET",
      headers: { 'Accept': 'application/json' },
    }
  )
  await renderDot(response)
  renderSources(response.sources)
}

const drawInitial = () => {
  history.pushState(null, null, '#')

  document.querySelector("[data-target='definition-title']").innerText = ''
  document.querySelector("[data-target='definition-id']").innerText = ''
  document.querySelector("[data-target='definition-graph']").innerHTML = ''
}

const drawCheckedDefinitions = async () => {
  const checkboxes = document.querySelectorAll("[data-target='definition-checkbox']:checked")
  const bitId = Array.from(checkboxes).map((el) => parseInt(el.getAttribute("data-id"), 10)).reduce((int, bitId) => int | bitId, 0)

  if (bitId === 0) {
    drawInitial()
  } else {
    drawDefinition(bitId)
  }
}

const definitionToggleChildren = (parentId, checked) => {
  const checkboxes = document.querySelectorAll("[data-target='definition-checkbox']")
  const ids = Array.from(checkboxes).map((el) => el.getAttribute("data-id"))
  const filteredIds = ids.filter((id) => id.startsWith(parentId))

  filteredIds.forEach((id) => {
    const checkbox = document.querySelector(`[data-id='${id}']`)
    checkbox.checked = checked
  })
}

const definitionCheckReset = () => {
  const checkboxes = document.querySelectorAll("[data-target='definition-checkbox']")

  checkboxes.forEach((checkbox) => {
    checkbox.checked = false
  })

  drawCheckedDefinitions()
}

const filterDefinitions = (value) => {
  const list = document.querySelectorAll("[data-target='definition-li']")
  value = value.toLowerCase()

  list.forEach((li) => {
    const title = li.getAttribute('data-title')
    const visible = value === "" || title.toLowerCase().includes(value)

    if (visible) {
      li.classList.remove('hidden')
    } else {
      li.classList.add('hidden')
    }
  })
}

const renderFromHash = (bitId) => {
  if (isNaN(bitId)) {
    return
  }

  const checkboxes = document.querySelectorAll("[data-target='definition-checkbox']")

  checkboxes.forEach((checkbox) => {
    const id = parseInt(checkbox.getAttribute('data-id'), 10)
    if ((bitId & id) !== 0) {
      checkbox.checked = true
    }
  })

  try {
    drawDefinition(bitId)
  } catch(e) {
    console.error(e)
  }
}

export const start = async () => {
  delegate(document, '[data-target="definition-checkbox"]', "change", debounse((event) => {
    definitionToggleChildren(event.target.getAttribute("data-id"), event.target.checked)

    drawCheckedDefinitions()
  }, 500))

  delegate(document, '[data-action="definitionCheckReset"]', 'click', () => {
    definitionCheckReset()
  })

  delegate(document, '[data-action="definition-filter-input"]', 'input', debounse((event) => {
    filterDefinitions(event.target.value)
  }, 100))

  const hash = window.location.hash
  if (hash) {
    const bitId = parseInt(hash.split("definition-")[1], 10)
    renderFromHash(bitId)
  }
}
