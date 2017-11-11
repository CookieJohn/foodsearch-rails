module I18nHelper
  def i18n_button model_name
    I18n.t("button.#{model_name}")
  end

  def i18n_label model_name
    I18n.t("label.#{model_name}")
  end

  def i18n_placeholder model_name
    I18n.t("placeholder.#{model_name}")
  end
end
