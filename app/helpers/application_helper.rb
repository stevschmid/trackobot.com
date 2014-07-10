module ApplicationHelper
  def nav_link(link_text, link_path, root = false)
    current = current_page?(link_path)
    current ||= root && current_page?(profile_path)

    class_name = current ? 'active' : ''

    content_tag(:li, :class => class_name) do
      link_to link_text, link_path
    end
  end

  def hero_name(hero_name, span_additions = nil)
    [
      hero_icon(hero_name),
      content_tag(:span, span_additions) { hero_name }
    ].join(' ').html_safe
  end

  def hero_icon(hero_name, additions = {})
    image_tag("classes/#{hero_name.downcase}.png", {width: '20px'}.merge(additions))
  end

  def show_feedback_button?
    current_user.feedbacks.where('created_at > ?', 1.day.ago).none?
  end

  def title(title)
    content_for :title, title
  end
end

