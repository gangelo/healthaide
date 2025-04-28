class ImportsController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_import_user, only: [ :import ]

  def index
    @import_user = nil
  end

  def upload
    @import_user = nil
    @import_user_hash = {}
    @import_user_json = "{}"

    if params[:json_file].present?
      service  = Imports::UploaderService.new(params[:json_file].read).execute
      if service.successful?
        @import_user = service.import_user
        @import_user_hash = service.import_user_hash
        @import_user_json = @import_user_hash.to_json
        flash[:notice] = "Import file for '#{@import_user.username}' uploaded successfully! Ready to import."
      else
        flash[:alert] = service.message
      end
    else
      flash.now[:alert] = "Please choose a file to import."
    end

    respond_to do |format|
      format.html { render partial: "imports/preview", locals: { import_user_hash: @import_user_hash } }
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("import_content",
                              partial: "imports/preview",
                              locals: { import_user_hash: @import_user_hash }),
          turbo_stream.update("import_form",
                              partial: "imports/import_form",
                              locals: {
                                import_user: @import_user,
                                import_user_json: @import_user_json
                              }),
          turbo_stream.update("import_user",
                              partial: "imports/import_user",
                              locals: { import_user: @import_user }),
          turbo_stream.update("flash_messages",
                              partial: "shared/flash_messages")
        ]
      end
    end
  end

  def import
    import_user_json = params[:import_user_json] || "{}"
    import_user_hash = JSON.parse(import_user_json).with_indifferent_access
    if @import_user
      service = Imports::ImporterService.new(import_user_hash).execute
      if service.successful?
        @import_user = service.import_user
        @import_user_hash = service.import_user_hash
        @import_user_json = @import_user_hash.to_json
        flash[:notice] = "User '#{@import_user.username}' successfully imported!"
      else
        flash[:alert] = service.message
      end
      flash[:notice] = "Import user '#{@import_user.username}' successfully imported."
    else
      flash[:alert] = "Import user could not be set!"
    end

    respond_to do |format|
      format.html { render partial: "imports/preview", locals: { import_user_hash: import_user_hash } }
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("import_content",
                              partial: "imports/preview",
                              locals: { import_user_hash: import_user_hash }),
          turbo_stream.update("import_form",
                              partial: "imports/import_form",
                              locals: {
                                import_user: @import_user,
                                import_user_json: import_user_json
                              }),
          turbo_stream.update("import_user",
                              partial: "imports/import_user",
                              locals: { import_user: @import_user }),
          turbo_stream.update("flash_messages",
                              partial: "shared/flash_messages")
        ]
      end
    end
  end

  private

  def set_import_user
    @import_user = User.find_by(id: params[:import_user_id])
  end
end
