class LocationInput
  include Formtastic::Inputs::Base

  def to_html
    input_wrapping do
      label_html << input_fields
    end
  end

  def input_fields
    template.content_tag(:div, class: 'location-picker', data: { picker: 'location', field_prefix: @object_name }) do
      loading_indicator <<
      address_error_indicator <<
      location_field <<
      action_buttons <<
      builder.hidden_field(:longitude) <<
      builder.hidden_field(:latitude)
    end
  end

  def location_field
    template.content_tag(:div, '', class: 'location-picker-map')
  end

  def loading_indicator
    template.content_tag(:div, class: 'location-picker-loading') do
      I18n.translate('location_picker.loading')
    end
  end

  def address_error_indicator
    template.content_tag(:div, class: 'location-picker-address-error') do
      I18n.translate('location_picker.address_not_found')
    end
  end

  def action_buttons
    template.content_tag(:div, class: 'location-picker-buttons') do
      action_button(:reset) << action_button(:search)
    end
  end

  def action_button(type)
    label = I18n.translate("location_picker.#{type}")
    template.content_tag(:button, label, class: "location-picker-#{type}-button", type: :button)
  end
end