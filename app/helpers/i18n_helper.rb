module I18nHelper
	def i18n_button model_name, locale: 'zh-TW'
		I18n.t("button.#{model_name}", locale: locale)
	end

	def i18n_label model_name, locale: 'zh-TW'
		I18n.t("label.#{model_name}", locale: locale)
	end

	def i18n_placeholder model_name, locale: 'zh-TW'
		I18n.t("placeholder.#{model_name}", locale: locale)
	end
end
