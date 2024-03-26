import { useEffect, useRef, useState } from "react"
import { useSearchParams } from "react-router-dom";

import {
  bitIdToIds,
  encode as bitIdToString,
  idsToBitId,
  decode as stringToBitId,
} from "@/utils/bitId"

const KEY = 'bit_id'

const encode = (ids: number[]): string => {
  const bitId = idsToBitId(ids)
  return bitIdToString(bitId)
}

const decode = (bitId64: string): number[] => {
  const bitId = stringToBitId(bitId64)
  return bitIdToIds(bitId)
}

export const useBitIdHash = () => {
  const [ids, setIds] = useState<number[]>([])
  const initialized = useRef<boolean>(false)
  const [searchParams, setSearchParams] = useSearchParams();

  // Load ids on load
  useEffect(() => {
    if (!initialized.current) {
      try {
        const value = searchParams.get(KEY)

        if (value) {
          setIds(decode(value))
        }
      } catch (e) {
        setSearchParams((prev) => ({ ...prev, [KEY]: '' }))
      }

      initialized.current = true
    }
  }, [initialized, setIds, searchParams, setSearchParams])

  useEffect(() => {
    if (!initialized.current) return

    setSearchParams((prev) => ({ ...prev, [KEY]: encode(ids) }))
  }, [ids, setSearchParams])

  return [ids, setIds] as const
}
