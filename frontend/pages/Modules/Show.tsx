import React, { useMemo } from 'react'
import { useParams } from 'react-router-dom'
import styled from 'styled-components'

import { Link } from '@/components/Link'
import { Loading } from '@/components/Loading'
import { Cluster, Heading, Section, Stack, TabBar, TabItem } from '@/components/ui'
import { path } from '@/constants/path'
import { spacing } from '@/constants/theme'
import { useModule } from '@/repositories/moduleRepository'
import { SourcesContent } from './components/SourcesContent/SourcesContent'
import { DependenciesContent } from './components/DependenciesContent'
import { ReverseDependenciesContent } from './components/ReverseDependenciesContent/ReverseDependenciesContent'
import { CircularDependenciesContent } from './components/CircularDependenciesContent'

export const Show: React.FC = () => {
  const pathModule = useParams()['*'] ?? ''
  const { data, isLoading } = useModule(pathModule)
  const [activeTab, setActiveTab] = React.useState<'sources' | 'dependencies' | 'reverseDependencies' | 'circularDependencies'>(
    'sources',
  )

  const content = useMemo(() => {
    if (isLoading || data === undefined) {
      return <Loading />
    }

    switch (activeTab) {
      case 'sources': {
        return <SourcesContent sources={data.sources} />
      }
      case 'dependencies': {
        return <DependenciesContent moduleDependencies={data.moduleDependencies} />
      }
      case 'reverseDependencies': {
        return <ReverseDependenciesContent modules={data.moduleReverseDependencies} sources={data.sourceReverseDependencies} />
      }
      case 'circularDependencies': {
        return <CircularDependenciesContent />
      }
      default: {
        throw new Error(`Invalid tab: ${activeTab}`)
      }
    }
  }, [data, isLoading, activeTab])

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
            <TabBar>
              <TabItem id="tab-sources" onClick={() => setActiveTab('sources')} selected={activeTab === 'sources'}>
                Sources{data ? ` (${data.sources.length})` : ''}
              </TabItem>
              <TabItem id="tab-dependencies" onClick={() => setActiveTab('dependencies')} selected={activeTab === 'dependencies'}>
                Dependencies{data ? ` (${data.moduleDependencies.length})` : ''}
              </TabItem>
              <TabItem
                id="tab-reverse-dependencies"
                onClick={() => setActiveTab('reverseDependencies')}
                selected={activeTab === 'reverseDependencies'}
              >
                Reverse Dependencies{data ? ` (${data.sourceReverseDependencies.length})` : ''}
              </TabItem>
              <TabItem
                id="tab-circular-dependencies"
                onClick={() => setActiveTab('circularDependencies')}
                selected={activeTab === 'circularDependencies'}
              >
                Circular Dependencies
              </TabItem>
            </TabBar>

            {content}
          </Stack>
        </Section>
      </Stack>
    </StyledSection>
  )
}

const StyledSection = styled(Section)`
  padding: ${spacing.XS};
`
