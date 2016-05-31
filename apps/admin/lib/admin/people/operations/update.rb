require "admin/import"
require "admin/entities/person"
require "admin/people/validation/form"
require "kleisli"
require "sequel"

module Admin
  module People
    module Operations
      class Update
        include Admin::Import(
          "admin.persistence.repositories.people",
          "core.authentication.encrypt_password"
        )

        include Dry::ResultMatcher.for(:call)

        def call(id, attributes)
          validation = Validation::Form.(prepare_attributes(attributes))

          if validation.success?
            people.update(id, validation.to_h)
            Right(people[id])
          else
            Left(validation)
          end
        end

        private

        def prepare_attributes(attributes)
          attributes.merge(
            previous_email: attributes["email"],
            avatar: Sequel.pg_json(attributes["avatar"])
          )
        end
      end
    end
  end
end