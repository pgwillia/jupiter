module JupiterCore
  extend ActiveSupport::Autoload

  class ObjectNotFound < StandardError; end

  class PropertyInvalidError < StandardError; end

  class MultipleIdViolationError < StandardError; end

  class AlreadyDefinedError < StandardError; end

  class LockedInstanceError < StandardError; end

  class SolrNameManglingError < StandardError; end

  class VocabularyMissingError < StandardError; end

  VISIBILITY_PUBLIC = CONTROLLED_VOCABULARIES[:era][:visibility].public.freeze
  VISIBILITY_PRIVATE = CONTROLLED_VOCABULARIES[:era][:visibility].private.freeze
  VISIBILITY_AUTHENTICATED = CONTROLLED_VOCABULARIES[:era][:visibility].authenticated.freeze

  VISIBILITIES = [VISIBILITY_PUBLIC, VISIBILITY_PRIVATE, VISIBILITY_AUTHENTICATED].freeze
end
