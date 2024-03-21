import { Pagination } from '@/models/pagination'

export type PaginationResponse = {
  totalPages: number
  currentPage: number
  totalCount: number
  per: number
}

export const toPagination = (res: PaginationResponse): Pagination => res
