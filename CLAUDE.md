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

## View Organization
- **Component Directory Structure**: Organize related view partials within a subdirectory under the resource
  - Example: `app/views/user_foods/list/_list.html.erb` instead of `app/views/user_foods/_user_foods_list.html.erb`
- **Namespace Conventions**: 
  - Avoid redundant naming (prefer `user_foods/list/_row.html.erb` over `user_foods/user_foods_list/_row.html.erb`)
  - Group related components in contextual directories (e.g., `list`, `form`, `card`)
- **ViewComponent Usage**: Use ViewComponents for reusable UI elements when appropriate
  - Example: `Grids::HeaderComponent` for table headers

## Turbo Frame Patterns
- **Standard Frame IDs**: 
  - Use `main_content` for the main resource listing
  - Use `modal` for modal dialogs
  - Use `flash_messages` for flash notifications
- **Controller Updates**:
  - Include Turbo Stream responses that update the appropriate frames
  - Example pattern for delete actions:
    ```ruby
    respond_to do |format|
      format.html { redirect_to user_foods_path, notice: "Food was successfully removed." }
      format.turbo_stream do
        flash.now[:notice] = "Food was successfully removed."
        render turbo_stream: [
          turbo_stream.update("main_content", partial: "user_foods/list/list", locals: { user_foods: @user_foods }),
          turbo_stream.update("flash_messages", partial: "shared/flash_messages")
        ]
      end
    end
    ```
- **Flash Messages**: Always set flash messages before rendering turbo_stream responses
  - Use `flash[:notice]` or `flash[:alert]` rather than passing locals to the partial

## Security & Best Practices
- Never commit secrets or API keys
- Validate all user input
- Use Devise for authentication
- Use proper error handling and logging
- Use Turbo for SPA-like experiences without excessive JavaScript
- Always ensure fallbacks for non-JavaScript scenarios