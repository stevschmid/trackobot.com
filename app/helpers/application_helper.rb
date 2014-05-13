module ApplicationHelper
  def nav_link(link_text, link_path, root = false)
    current = current_page?(link_path)
    current ||= root && current_page?(profile_path)

    class_name = current ? 'active' : ''

    content_tag(:li, :class => class_name) do
      link_to link_text, link_path
    end
  end

  def hero_name(hero_name)
    [
      image_tag("classes/#{hero_name.downcase}.png", width: '20px'),
      hero_name
    ].join(' ').html_safe
  end
end

