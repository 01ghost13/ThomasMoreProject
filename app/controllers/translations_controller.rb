class TranslationsController < AdminController
  translations_for_preload %i[
    entities.translations.index
    common.menu.all
    common.menu.create
    common.menu.log_out
    common.menu.my_profile
    common.menu.profile
    common.menu.settings
    entities.clients.create
    entities.clients.index
    entities.interests.index
    entities.local_administrators.create
    entities.local_administrators.index
    entities.mentors.create
    entities.mentors.index
    entities.pictures.index
    entities.tests.index
    entities.translations.all_translations
  ]

  helper_method :active_tab?

  def index
    authorize!

    index_initialize
    @active_tab_id = params[:active_tab]
  end

  def update
    authorize!

    @translation = Translation.find(params[:id])

    if @translation.update(translation_params)
      flash[:success] = tf('common.flash.translation_updated')

      redirect_to translations_path(active_tab: @translation.language_id)
    else
      index_initialize
      @user = @translation
      @active_tab_id = @translation.language_id

      render :index
    end
  end

  def create
    authorize!

    @translation = Translation.new(translation_params)

    if @translation.save
      flash[:success] = tf('common.flash.translation_updated')

      redirect_to translations_path(active_tab: @translation.language_id)
    else
      index_initialize
      @user = @translation
      @active_tab_id = @translation.language_id

      render :index
    end
  end

  def create_language
    authorize!

    @language = Language.new(language_params)

    if @language.save
      flash[:success] = tf('common.flash.language_created')

      redirect_to translations_path
    else
      index_initialize
      @user = @language

      render :index
    end
  end

  def create_translated_columns
    authorize!

    @translation = TranslatedColumn.new(translated_column_params)

    if @translation.save
      flash[:success] = tf('common.flash.translation_updated')

      redirect_to translations_path(active_tab: @translation.language_id)
    else
      index_initialize
      @user = @translation
      @active_tab_id = @translation.language_id

      render :index
    end
  end

  def update_translated_columns
    authorize!

    @translation = Translation.find(params[:id])

    if @translation.update(translated_column_params)
      flash[:success] = tf('common.flash.translation_updated')

      redirect_to translations_path(active_tab: @translation.language_id)
    else
      index_initialize
      @user = @translation
      @active_tab_id = @translation.language_id

      render :index
    end
  end

  private

    def translated_column_params
      params
        .require(:translated_column)
        .permit(TranslatedColumn.attribute_names)
    end

    def translation_params
      params
        .require(:translation)
        .permit(Translation.attribute_names)
    end

    def language_params
      params
        .require(:language)
        .permit(:name)
    end

    def index_initialize
      @language ||= Language.new
      @translations_presenter = TranslationIndex.new
    end

    def active_tab?(id, index)
      @active_tab_id.to_s == id.to_s || @active_tab_id.blank? && index.zero?
    end
end
