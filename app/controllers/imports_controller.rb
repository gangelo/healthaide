class ImportsController < ApplicationController
  before_action :authenticate_admin!

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
        flash.now[:notice] = "Import file for '#{@import_user.username}' uploaded successfully! Ready to import."
      else
        flash.now[:alert] = service.message
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
    import_user = User.find_by(id: params[:import_user_id])
    if import_user
      import_user_json = params[:import_user_json] || "{}"
      import_user_hash = JSON.parse(import_user_json).with_indifferent_access
      service = Imports::ImporterService.new(import_user_hash).execute
      if service.successful?
        flash.now[:notice] = "User '#{service.import_user.username}' successfully imported!"
      else
        flash.now[:alert] = service.message
      end
    else
      flash.now[:alert] = "Import user could not be imported. Please try again."
    end

    @import_user = nil

    respond_to do |format|
      format.html { render :index }
    end
  end
end
