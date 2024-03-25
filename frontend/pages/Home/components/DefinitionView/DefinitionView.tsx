import { FC } from "react"

import { Loading } from "@/components/Loading"
import { useCombinedDefinition } from "@/repositories/combinedDefinitionRepository"

type Props = {
  definitionIds: number[]
}

export const DefinitionView: FC<Props> = ({ definitionIds }) => {
  const { data, isLoading } = useCombinedDefinition(definitionIds)

  if (isLoading) {
    return (<Loading text="Loading..." alt="Loading" />)
  } else {
    return (
      <div>
        {data?.ids}
        {data?.title}
        {data?.dot}
      </div>
    )
  }
}
