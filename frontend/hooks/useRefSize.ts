import { useCallback, useRef, useState } from "react";

type Size = {
  width: number | undefined
  height: number | undefined
}

export const useRefSize = <T extends HTMLElement>() => {
  const [size, setSize] = useState<Size>({ width: undefined, height: undefined })
  const observer = useRef<ResizeObserver | null>(null)
  const element = useRef<T | null>(null)

  const handleResize = useCallback((entries: ResizeObserverEntry[]) => {
    const entry = entries[0];
    setSize({ width: entry.contentBoxSize[0].inlineSize, height: entry.contentBoxSize[0].blockSize });
  }, []);

  // initialize resize observer
  const observeRef = useCallback((target: T) => {
    if (!target) {
      return;
    }

    if (!observer.current) {
      observer.current = new ResizeObserver((entries) => handleResize(entries));
    }

    if (element.current !== target) {
      if (element.current) {
        observer.current.disconnect()
      }

      element.current = target
      observer.current.observe(target)
    }
  }, [handleResize])

  return { observeRef, size };
}
