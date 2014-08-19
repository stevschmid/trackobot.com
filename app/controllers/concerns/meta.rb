module Meta
  extend ActiveSupport::Concern

  def meta(object)
    {
      current_page: object.current_page,
      next_page: object.next_page,
      prev_page: object.prev_page,
      total_pages: object.total_pages,
      total_items: object.total_count
    }
  end
end
