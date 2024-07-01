import React, { useMemo } from 'react'
import { useParams } from 'react-router-dom'
import styled from 'styled-components'

import { Link } from '@/components/Link'
import { Loading } from '@/components/Loading'
import { Chip, Cluster, Heading, Section, Stack, TabBar, TabItem } from '@/components/ui'
import { path } from '@/constants/path'
import { color, spacing } from '@/constants/theme'
import { useModule } from '@/repositories/moduleRepository'
import { SourcesContent } from './components/SourcesContent/SourcesContent'
import { ModuleDependenciesContent } from './components/ModuleDependenciesContent'
import { SourceReverseDependenciesContent } from './components/SourceReverseDependenciesContent'
import { useSearchParamsState } from '@/hooks/useSearchParams'
import { Module } from '@/models/module'

const validTabs = ['sources', 'sourceReverseDependencies', 'moduleDependencies', 'moduleReverseDependencies'] as const
type ValidTab = (typeof validTabs)[number]

type Query = {
  module: Module | null
}

export const Show: React.FC = () => {
  const pathModule = useParams()['*'] ?? ''
  const { data, isLoading } = useModule(pathModule)
  const [params, setParams] = useSearchParamsState<{ tab: ValidTab; q: Query }>({
    tab: (val: any) => (validTabs.includes(String(val) as ValidTab) ? (String(val) as ValidTab) : 'sources'),
    q: (val: any) => {
      const q: Query = { module: null }

      if (val && val.module) {
        q.module = val.module
      }

      return q
    },
  })

  const content = useMemo(() => {
    if (isLoading || data === undefined) {
      return <Loading />
    }

    switch (params.tab) {
      case 'sources': {
        return <SourcesContent sources={data.sources} filteredModule={params.q.module} />
      }
      case 'moduleDependencies': {
        return (
          <ModuleDependenciesContent
            pathModule={pathModule}
            sources={data.sources}
            moduleDependencies={data.moduleDependencies}
          />
        )
      }
      case 'moduleReverseDependencies': {
        return (
          <ModuleDependenciesContent
            pathModule={pathModule}
            sources={data.sources}
            moduleDependencies={data.moduleReverseDependencies}
          />
        )
      }
      case 'sourceReverseDependencies': {
        return <SourceReverseDependenciesContent filteredModule={params.q.module} sources={data.sourceReverseDependencies} />
      }
      default: {
        throw new Error(`Invalid tab: ${params.tab}`)
      }
    }
  }, [data, pathModule, isLoading, params])

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
              <TabItem
                id="tab-source-reverse-dependencies"
                onClick={() => setParams((prev) => ({ ...prev, tab: 'sourceReverseDependencies' }))}
                selected={params.tab === 'sourceReverseDependencies'}
              >
                Source Reverse Dependencies{data ? ` (${data.sourceReverseDependencies.length})` : ''}
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
