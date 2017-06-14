module ApplicationHelper
	def i18n_button model_name, locale: 'zh-TW'
		I18n.t("button.#{model_name}", locale: locale)
	end
end
