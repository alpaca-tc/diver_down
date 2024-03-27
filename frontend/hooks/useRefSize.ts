import { useCallback, useSyncExternalStore } from "react";

export const useRefSize = (ref: React.RefObject<HTMLElement>): [number | undefined, number | undefined] => {
  const subscribe = useCallback((onStoreChange: () => void) => {
    const observer = new ResizeObserver(onStoreChange)

    if (ref.current) {
      observer.observe(ref.current);
    }

    return () => {
      observer.disconnect();
    }
  }, [ref]);

  const width = useSyncExternalStore(
    subscribe,
    () => ref.current?.clientWidth,
  );

  const height = useSyncExternalStore(
    subscribe,
    () => ref.current?.clientHeight,
  );

  return [width, height]
}
