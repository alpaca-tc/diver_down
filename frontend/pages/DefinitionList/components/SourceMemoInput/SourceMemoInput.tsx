import React, { FC, useCallback, useEffect, useState } from 'react'

import { Button, Cluster, FaXmarkIcon, FormControl, Input, Textarea } from '@/components/ui'
import { useSourceMemo } from '@/repositories/sourceMemoRepository'

type Props = {
  sourceName: string
  initialMemo: string
  onClose: () => void
  onUpdate: () => void
}

export const SourceMemoInput: FC<Props> = ({ sourceName, initialMemo, onClose, onUpdate }) => {
  const { trigger } = useSourceMemo(sourceName)

  const [memo, setMemo] = useState<string>(initialMemo)

  const handleUpdate = useCallback(async () => {
    await trigger({ memo })
    onUpdate()
  }, [trigger, memo, onUpdate])

  const onInputMemo = useCallback(
    (event: React.ChangeEvent<HTMLTextAreaElement | HTMLInputElement>) => {
      setMemo(event.target.value)
    },
    [setMemo],
  )

  return (
    <Cluster>
      <div>
        <FormControl title="Memo" helpMessage="Free memo field.">
          <Textarea onChange={onInputMemo} value={memo} autoResize />
        </FormControl>
      </div>
      <Button square={true} variant="primary" onClick={handleUpdate} size="s">
        Update
      </Button>
      <Button square={true} onClick={onClose} size="s">
        <FaXmarkIcon alt="Cancel" />
      </Button>
    </Cluster>
  )
}
