class DuplicatePostFinder
  DEFAULT_LIMIT = 5

  def initialize(title:, body:, exclude_id: nil, limit: DEFAULT_LIMIT)
    @title = title.to_s.strip
    @body = body.to_s.strip
    @exclude_id = exclude_id
    @limit = limit
  end

  def call
    return Post.none if search_terms.empty?

    scope = Post.active.order(created_at: :desc)
    scope = scope.where.not(id: exclude_id) if exclude_id.present?
    scope.where(search_clause, *search_terms).limit(@limit)
  end

  private

  attr_reader :title, :body, :exclude_id

  def search_clause
    clauses = []
    clauses << 'LOWER(title) LIKE ?' if title.present?
    clauses << 'LOWER(body) LIKE ?' if body.present?
    clauses.join(' OR ')
  end

  def search_terms
    terms = []
    terms << "%#{title.downcase}%" if title.present?
    terms << "%#{body.downcase[0, 120]}%" if body.present?
    terms
  end
end
