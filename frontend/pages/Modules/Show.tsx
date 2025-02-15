import React, { useMemo } from 'react'
import { useParams } from 'react-router-dom'
import styled from 'styled-components'

import { Link } from '@/components/Link'
import { Loading } from '@/components/Loading'
import { Chip, Cluster, Heading, Section, Stack, Text, TabBar, TabItem, Button, FaXmarkIcon } from '@/components/ui'
import { path } from '@/constants/path'
import { color, spacing } from '@/constants/theme'
import { useModule } from '@/repositories/moduleRepository'
import { SourcesContent } from './components/SourcesContent/SourcesContent'
import { ModuleDependenciesContent } from './components/ModuleDependenciesContent'
import { stringify } from '@/utils/queryString'
import { Params, useModuleParams } from './hooks/useModuleParams'
import { ModuleReverseDependenciesContent } from './components/ModuleReverseDependenciesContent'

export const Show: React.FC = () => {
  const pathModule = useParams()['*'] ?? ''
  const { data, isLoading, mutate } = useModule(pathModule)
  const [params, setParams] = useModuleParams()

  const content = useMemo(() => {
    if (isLoading || data === undefined) {
      return <Loading />
    }

    switch (params.tab) {
      case 'sources': {
        return <SourcesContent mutate={mutate} sources={data.sources} filteredModule={params.filteredModule} />
      }
      case 'moduleDependencies': {
        return (
          <ModuleDependenciesContent
            mutate={mutate}
            pathModule={pathModule}
            sources={data.sources}
            moduleDependencies={data.moduleDependencies}
          />
        )
      }
      case 'moduleReverseDependencies': {
        return (
          <ModuleReverseDependenciesContent
            mutate={mutate}
            pathModule={pathModule}
            sources={data.sourceReverseDependencies}
            moduleDependencies={data.moduleReverseDependencies}
          />
        )
      }
      default: {
        throw new Error(`Invalid tab: ${params.tab}`)
      }
    }
  }, [data, pathModule, isLoading, params])

  const pathToModule = (newParams: Params) => {
    return `${path.modules.show(pathModule)}?${stringify(newParams)}`
  }

  return (
    <StyledSection>
      <Stack>
        <Heading type="screenTitle">
          <Cluster>
            <Link to={path.modules.index()}>Module List</Link>
            &gt;
            <Link to={path.modules.show(pathModule)}>{pathModule}</Link>
          </Cluster>
        </Heading>

        {params.filteredModule && (
          <Cluster>
            <Chip size="s">
              <Cluster align="center">
                <Text>Filter: {params.filteredModule}</Text>
                <TextLink reloadDocument to={pathToModule({ ...params, filteredModule: null })}>
                  <FaXmarkIcon />
                </TextLink>
              </Cluster>
            </Chip>
          </Cluster>
        )}

        <Section>
          <Stack gap={1.5}>
            <StickyTabBar>
              <TabItem
                id="tab-sources"
                onClick={() => setParams((prev) => ({ ...prev, tab: 'sources' }))}
                selected={params.tab === 'sources'}
              >
                Sources{data ? ` (${data.sources.length})` : ''}
              </TabItem>
              <TabItem
                id="tab-dependencies"
                onClick={() => setParams((prev) => ({ ...prev, tab: 'moduleDependencies' }))}
                selected={params.tab === 'moduleDependencies'}
              >
                Module Dependencies{data ? ` (${data.moduleDependencies.length})` : ''}
              </TabItem>
              <TabItem
                id="tab-module-reverse-dependencies"
                onClick={() => setParams((prev) => ({ ...prev, tab: 'moduleReverseDependencies' }))}
                selected={params.tab === 'moduleReverseDependencies'}
              >
                Module Reverse Dependencies{data ? ` (${data.moduleReverseDependencies.length})` : ''}
              </TabItem>
            </StickyTabBar>

            {content}
          </Stack>
        </Section>
      </Stack>
    </StyledSection>
  )
}

const StickyTabBar = styled(TabBar)`
  position: sticky;
  top: 0;
  z-index: 1;
  background: ${color.BACKGROUND};
`

const StyledSection = styled(Section)`
  padding: ${spacing.XS};
`

const TextLink = styled(Link)`
  color: ${color.TEXT_GREY};
`
