import React, { useMemo } from 'react'
import { useParams } from 'react-router-dom'
import styled from 'styled-components'

import { Link } from '@/components/Link'
import { Loading } from '@/components/Loading'
import { Cluster, Heading, Section, Stack, TabBar, TabItem } from '@/components/ui'
import { path } from '@/constants/path'
import { color, spacing } from '@/constants/theme'
import { useModule } from '@/repositories/moduleRepository'
import { SourcesContent } from './components/SourcesContent/SourcesContent'
import { ModuleDependenciesContent } from './components/ModuleDependenciesContent'
import { SourceReverseDependenciesContent } from './components/SourceReverseDependenciesContent'
import { CircularDependenciesContent } from './components/CircularDependenciesContent'
import { useSearchParamsState } from '@/hooks/useSearchParams'
import { Module } from '@/models/module'

const validTabs = ['sources', 'sourceReverseDependencies', 'moduleDependencies', 'moduleReverseDependencies', 'circularDependencies'] as const
type ValidTab = (typeof validTabs)[number]

export const Show: React.FC = () => {
  const pathModule = useParams()['*'] ?? ''
  const { data, isLoading } = useModule(pathModule)
  const [params, setParams] = useSearchParamsState<{ tab: ValidTab }>({
    tab: (val: any) => (validTabs.includes(String(val) as ValidTab) ? (String(val) as ValidTab) : 'sources'),
  })

  const content = useMemo(() => {
    if (isLoading || data === undefined) {
      return <Loading />
    }

    switch (params.tab) {
      case 'sources': {
        return <SourcesContent sources={data.sources} />
      }
      case 'moduleDependencies': {
        return <ModuleDependenciesContent moduleDependencies={data.moduleDependencies} />
      }
      case 'moduleReverseDependencies': {
        return <ModuleDependenciesContent moduleDependencies={data.moduleReverseDependencies} />
      }
      case 'sourceReverseDependencies': {
        return <SourceReverseDependenciesContent sources={data.sourceReverseDependencies} />
      }
      case 'circularDependencies': {
        return <CircularDependenciesContent />
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
              <TabItem
                id="tab-circular-dependencies"
                onClick={() => setParams((prev) => ({ ...prev, tab: 'circularDependencies' }))}
                selected={params.tab === 'circularDependencies'}
              >
                Circular Dependencies
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
