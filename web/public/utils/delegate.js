const matches = (element, selector) => {
  if (selector.exclude) {
    return Element.prototype.matches.call(element, selector.selector) && !Element.prototype.matches.call(element, selector.exclude);
  } else {
    return Element.prototype.matches.call(element, selector);
  }
};

export const delegate = (element, selector, eventType, handler) => {
  element.addEventListener(eventType, (e) => {
    let {target: target} = e;
    while (!!(target instanceof Element) && !matches(target, selector)) {
      target = target.parentNode;
    }
    if (target instanceof Element && handler.call(target, e) === false) {
      e.preventDefault();
      e.stopPropagation();
    }
  })
}
