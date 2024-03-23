import { Pagination } from '@/models/pagination'

export type PaginationResponse = {
  total_pages: number
  current_page: number
  total_count: number
  per: number
}

export const toPagination = (res: PaginationResponse): Pagination => ({
  per: res.per,
  totalPages: res.total_pages,
  currentPage: res.current_page,
  totalCount: res.total_count,
})
