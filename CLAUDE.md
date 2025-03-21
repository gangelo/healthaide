# HealthAide Development Guidelines

## Build & Run Commands
- **Start dev server**: `bin/dev`
- **Run all tests**: `bin/rails spec`
- **Run single test**: `bin/rails spec SPEC=path/to/spec.rb:line_number`
- **Lint Ruby code**: `bin/rubocop`
- **Lint ERB files**: `bundle exec erb_lint --lint-all`
- **Security scan**: `bin/brakeman`

## Code Style Guidelines
- **Ruby**: Follow Rails Omakase style (RuboCop enforced)
- **String literals**: Use double quotes (`"`)
- **Documentation**: Add descriptive comments for classes/modules
- **Naming**: Use snake_case for variables/methods, CamelCase for classes
- **Error Handling**: Use `rescue_from` in controllers for specific errors
- **Models**: Include validations, relationships at top of class
- **Controller Organization**: Private/protected methods at bottom
- **Database Changes**: Always use migrations
- **Tests**: Use RSpec, FactoryBot for fixtures
- **UI Components**: Follow view_component pattern in app/views/components

## Security & Best Practices
- Never commit secrets or API keys
- Validate all user input
- Use Devise for authentication
- Use proper error handling and logging