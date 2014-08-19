module ApplicationHelper

  def profile_page(title, footer_info = {}, &block)
    content_for(:title, title)
    content_tag(:div, class: 'container') do
      [
        render(partial: '/layouts/header'),
        capture(&block),
        render(partial: '/layouts/footer', locals: footer_info)
      ].join.html_safe
    end
  end

  def nav_link(link_text, link_path, root = false)
    current = current_page?(link_path)
    current ||= root && current_page?(profile_path)

    class_name = current ? 'active' : ''

    content_tag(:li, :class => class_name) do
      link_to link_text, link_path
    end
  end

  def show_feedback_button?
    current_user.feedbacks.where('created_at > ?', 1.day.ago).none?
  end
end

